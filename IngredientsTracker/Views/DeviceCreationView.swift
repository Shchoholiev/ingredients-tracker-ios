//
//  DeviceCreationView.swift
//  IngredientsTracker
//
//  Created by Serhii Shchoholiev on 5/18/24.
//

import SwiftUI

struct DeviceCreationView: View {
    @State private var deviceName: String = ""
    @State private var selectedDeviceType: DeviceType = .unknown
    @State private var errorMessage: String?
    @State private var result: DeviceCreateDto?
    
    private var devicesService = DevicesService()

    private let deviceTypes = [
        (value: DeviceType.unknown, text: DeviceType.unknown.toString()),
        (value: DeviceType.productsRecognizer, text: DeviceType.productsRecognizer.toString()),
    ]

    var body: some View {
        VStack() {
            Text("Create Device")
                .font(.title)
                .padding(.bottom, 5)

            Text("Enter details to create a new device")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Form {
                Section(header: Text("Name")) {
                    TextField("Device Name", text: $deviceName)
                }
                
                Section {
                    Picker("Device Type", selection: $selectedDeviceType) {
                        ForEach(deviceTypes, id: \.value) { type in
                            Text(type.text).tag(type.value)
                        }
                    }
                }
            }
            .frame(height: 180)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button(action: createDevice) {
                Text("Create Device")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .padding([.top, .bottom], 14)
                    .padding([.leading, .trailing], 18)
                    .foregroundColor(.white)
                    .background(.blue)
                    .opacity(isFormValid ? 1 : 0.5)
                    .cornerRadius(40)
            }
            .disabled(!isFormValid)

            if let result = result {
                Form {
                    HStack {
                        Text("Id: ").bold() + Text("\(result.id)")
                        Spacer()
                        Button(action: { copyToClipboard(text: result.id) }) {
                            Image(systemName: "doc.on.doc.fill")
                        }
                    }

                    HStack {
                        Text("GUID: ").bold() + Text("\(result.guid)")
                        Spacer()
                        Button(action: { copyToClipboard(text: result.guid) }) {
                            Image(systemName: "doc.on.doc.fill")
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var isFormValid: Bool {
        !deviceName.isEmpty && selectedDeviceType != .unknown
    }
    
    private func copyToClipboard(text: String) {
            UIPasteboard.general.string = text
        }

    private func createDevice() {
        let device = Device(
            id: "",
            name: deviceName,
            type: selectedDeviceType,
            guid: "",
            groupId: nil,
            isActive: true
        )

        Task {
            do {
                let createdDevice = try await devicesService.createDevice(device)
                result = createdDevice
                
                deviceName = ""
                selectedDeviceType = .unknown
                errorMessage = nil
            } catch let httpError as HttpError {
                errorMessage = httpError.message
            }
        }
    }
}

#Preview {
    DeviceCreationView()
}
