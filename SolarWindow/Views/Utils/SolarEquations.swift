import Foundation
import CoreLocation

fileprivate extension Double {
    var toRad: Double { self * .pi / 180.0 }
    var toDeg: Double { self * 180.0 / .pi }
}

struct SolarPosition {
    let elevation: Double  // degrees above horizon
    let azimuth: Double    // degrees from North
}

struct Solar {
    static func position(date utcDate: Date, latitude lat: CLLocationDegrees, longitude lon: CLLocationDegrees) -> SolarPosition {
        let jd = julianDay(from: utcDate)
        let T = (jd - 2451545.0) / 36525.0

        let L0 = normalizeDegrees(280.46646 + 36000.76983 * T + 0.0003032 * T * T)
        let M = normalizeDegrees(357.52911 + 35999.05029 * T - 0.0001537 * T * T)
        let e = 0.016708634 - 0.000042037 * T - 0.0000001267 * T * T

        let Mr = M.toRad
        let C = (1.914602 - 0.004817 * T - 0.000014 * T * T) * sin(Mr)
              + (0.019993 - 0.000101 * T) * sin(2 * Mr)
              + 0.000289 * sin(3 * Mr)

        let trueLong = L0 + C
        let omega = 125.04 - 1934.136 * T
        let lambda = trueLong - 0.00569 - 0.00478 * sin(omega.toRad)

        let eps0 = 23.0 + (26.0 + (21.448 - T*(46.815 + T*(0.00059 - T*0.001813)))/60.0)/60.0
        let eps = eps0 + 0.00256 * cos(omega.toRad)

        let delta = asin(sin(eps.toRad) * sin(lambda.toRad))

        let y = pow(tan(eps.toRad / 2.0), 2.0)
        let L0r = L0.toRad
        let Erad = y * sin(2 * L0r) - 2 * e * sin(Mr) + 4 * e * y * sin(Mr) * cos(2 * L0r)
                   - 0.5 * y * y * sin(4 * L0r) - 1.25 * e * e * sin(2 * Mr)
        let eqTime = 4.0 * Erad.toDeg

        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = cal.dateComponents([.hour, .minute, .second], from: utcDate)
        let minutesUTC = Double(comps.hour ?? 0) * 60.0 + Double(comps.minute ?? 0) + Double(comps.second ?? 0) / 60.0

        var trueSolarTime = minutesUTC + lon * 4.0 + eqTime
        while trueSolarTime < 0 { trueSolarTime += 1440 }
        while trueSolarTime >= 1440 { trueSolarTime -= 1440 }

        let hourAngleDeg = trueSolarTime / 4.0 - 180.0
        let H = hourAngleDeg.toRad
        let phi = lat.toRad

        // Elevation
        let sinAlt = sin(phi) * sin(delta) + cos(phi) * cos(delta) * cos(H)
        var altitude = asin(clamp(sinAlt, min: -1.0, max: 1.0)).toDeg

        // Refraction correction
        if altitude > -0.575 {
            let pressure = 1013.25
            let temperatureC = 15.0
            let altRad = altitude.toRad
            let refractionDeg = (0.00452 * pressure) / ((273.0 + temperatureC) * tan(altRad + 0.00312536 / (altRad + 0.089011)))
            altitude += refractionDeg
        }

        // Azimuth
        let cosAz = (sin(delta) - sin(phi) * sinAlt) / (cos(phi) * cos(asin(sinAlt)))
        var azimuth = acos(clamp(cosAz, min: -1.0, max: 1.0)).toDeg

        if sin(H) > 0 {
            azimuth = 360.0 - azimuth
        }

        return SolarPosition(elevation: altitude, azimuth: azimuth)
    }

    // MARK: helpers
    private static func julianDay(from date: Date) -> Double {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        var Y = comps.year!
        var M = comps.month!
        let D = Double(comps.day!) + (Double(comps.hour!) / 24.0) + (Double(comps.minute!) / 1440.0) + (Double(comps.second!) / 86400.0)

        if M <= 2 {
            Y -= 1
            M += 12
        }
        let A = floor(Double(Y) / 100.0)
        let B = 2 - A + floor(A / 4.0)

        return floor(365.25 * Double(Y + 4716)) + floor(30.6001 * Double(M + 1)) + D + B - 1524.5
    }

    private static func normalizeDegrees(_ deg: Double) -> Double {
        var d = deg.truncatingRemainder(dividingBy: 360.0)
        if d < 0 { d += 360.0 }
        return d
    }

    private static func clamp(_ v: Double, min: Double, max: Double) -> Double {
        if v < min { return min }
        if v > max { return max }
        return v
    }
}
