import Foundation

enum MetricType: String, Codable, CaseIterable {
    case weight     = "weight"
    case glucose    = "glucose"
    case heartRate  = "heartRate"
    case medication = "medication"
    case temperature = "temperature"
    case notes      = "notes"

    var unit: String {
        switch self {
        case .weight:      return "lbs"
        case .glucose:     return "mg/dL"
        case .heartRate:   return "bpm"
        case .medication:  return "mg"
        case .temperature: return "°F"
        case .notes:       return ""
        }
    }

    var displayName: String {
        switch self {
        case .weight:      return "Weight"
        case .glucose:     return "Blood Glucose"
        case .heartRate:   return "Heart Rate"
        case .medication:  return "Medication"
        case .temperature: return "Temperature"
        case .notes:       return "Notes"
        }
    }
}

struct HealthMetric: Codable, Identifiable {
    let id: String       // MetricId from DynamoDB
    let petRef: String   // PetId reference
    let type: MetricType
    let value: String
    let unit: String
    let notes: String
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case id = "PetId"
        case petRef, type = "type", value, unit, notes, timestamp
    }
}

struct LogMetricRequest: Codable {
    let petId: String
    let type: MetricType
    let value: String
    let unit: String
    let notes: String?
}
