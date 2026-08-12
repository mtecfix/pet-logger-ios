import SwiftUI

struct MedicationScheduleView: View {
    let pet: Pet
    @StateObject private var notif = NotificationManager.shared
    @State private var medicationName = ""
    @State private var hourString = "8"
    @State private var minuteString = "0"
    @State private var scheduled = false
    @State private var scheduledMeds: [ScheduledMedication] = []

    struct ScheduledMedication: Identifiable, Codable {
        let id: String
        let petId: String
        let petName: String
        let medicationName: String
        let hour: Int
        let minute: Int
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Schedule Medication Reminder") {
                    TextField("Medication name", text: $medicationName)
                    HStack {
                        TextField("Hour (0-23)", text: $hourString).keyboardType(.numberPad).frame(width: 80)
                        Text(":")
                        TextField("Minute", text: $minuteString).keyboardType(.numberPad).frame(width: 80)
                    }
                    Button(action: schedule) {
                        Label("Add Reminder", systemImage: "bell.badge.fill")
                    }
                    .disabled(medicationName.isEmpty)
                }

                if !scheduledMeds.isEmpty {
                    Section("Active Reminders") {
                        ForEach(scheduledMeds) { med in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(med.medicationName).font(.headline)
                                    Text(String(format: "Daily at %02d:%02d", med.hour, med.minute))
                                        .font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(role: .destructive) { cancel(med) } label: {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                }
                            }
                        }
                    }
                }

                Section("Permission") {
                    HStack {
                        Image(systemName: notif.permissionGranted ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(notif.permissionGranted ? .green : .orange)
                        Text(notif.permissionGranted ? "Notifications enabled" : "Notifications not enabled")
                        Spacer()
                        if !notif.permissionGranted {
                            Button("Enable") {
                                Task { await notif.requestPermission() }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                    }
                }
            }
            .navigationTitle("Medication Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadScheduled() }
        }
    }

    func schedule() {
        let hour   = Int(hourString) ?? 8
        let minute = Int(minuteString) ?? 0
        let id     = "med-\(pet.id)-\(medicationName)-\(hour)-\(minute)"

        notif.scheduleDailyReminder(
            id: id,
            title: "\(pet.name) Medication",
            body: "Time to give \(pet.name) their \(medicationName)",
            hour: hour,
            minute: minute
        )

        let med = ScheduledMedication(id: id, petId: pet.id, petName: pet.name,
            medicationName: medicationName, hour: hour, minute: minute)
        scheduledMeds.append(med)
        saveScheduled()
        medicationName = ""
    }

    func cancel(_ med: ScheduledMedication) {
        notif.cancel(id: med.id)
        scheduledMeds.removeAll { $0.id == med.id }
        saveScheduled()
    }

    func saveScheduled() {
        if let data = try? JSONEncoder().encode(scheduledMeds) {
            UserDefaults.standard.set(data, forKey: "scheduled_meds_\(pet.id)")
        }
    }

    func loadScheduled() {
        if let data = UserDefaults.standard.data(forKey: "scheduled_meds_\(pet.id)"),
           let meds = try? JSONDecoder().decode([ScheduledMedication].self, from: data) {
            scheduledMeds = meds
        }
    }
}
