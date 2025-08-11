import Foundation
import CoreBluetooth
import CoreLocation
import Combine
enum ConnectionStatus {
    case idle, sending, success, failure
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate {
    
    @Published var devices: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var selectedPeripheral: CBPeripheral?
    @Published var ipAddress: String? = nil
    @Published var connectionStatus: ConnectionStatus = .idle // ✅ Track connection progress
    
    private var centralManager: CBCentralManager!
    private var locationManager: CLLocationManager!
    private var writeCharacteristic: CBCharacteristic?
    private var ipAddressCharacteristic: CBCharacteristic?

    private let SERVICE_UUID = CBUUID(string: "91bad492-b950-4226-aa2b-4ede9fa42f59")
    private let WIFI_CRED_UUID = CBUUID(string: "cba1d466-344c-4be3-ab3f-189f80dd7518")
    private let IP_ADDR_UUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        } else {
            print("Location permission denied. BLE scanning might not work properly.")
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            devices.removeAll()
            centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.contains("ESP32") {
            if !devices.contains(where: { $0.identifier == peripheral.identifier }) {
                DispatchQueue.main.async {
                    self.devices.append(peripheral)
                }
            }
        }
    }

    func connect(to peripheral: CBPeripheral) {
        selectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral)
        centralManager.stopScan()
    }

    func disconnect(peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnected")
        selectedPeripheral = nil
        isConnected = false
        ipAddress = nil
        writeCharacteristic = nil
        ipAddressCharacteristic = nil
    }

    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([SERVICE_UUID])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([WIFI_CRED_UUID, IP_ADDR_UUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == WIFI_CRED_UUID {
                writeCharacteristic = characteristic
            }
            else if characteristic.uuid == IP_ADDR_UUID {
                ipAddressCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error receiving update for characteristic \(characteristic.uuid): \(error.localizedDescription)")
            self.connectionStatus = .failure
            return
        }
        
        if characteristic.uuid == IP_ADDR_UUID {
            if let data = characteristic.value,
               let ipString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.ipAddress = ipString
                    print("Received IP Address from ESP32: \(ipString)")
                    self.connectionStatus = .success // ✅ IP received = Wi-Fi connected
                }
            } else {
                self.connectionStatus = .failure
            }
        }
    }

    func sendWiFiCredentials(ssid: String, password: String) {
        guard let peripheral = selectedPeripheral,
              let characteristic = writeCharacteristic else {
            print("Not ready to send data")
            return
        }

        connectionStatus = .sending // ✅ Start loading

        let payload = ["ssid": ssid, "password": password]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        } catch {
            print("Failed to serialize Wi-Fi credentials")
            connectionStatus = .failure
        }
    }
}

extension CBPeripheral: Identifiable {
    public var id: UUID { identifier }
}
