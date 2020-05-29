import SwiftUI
import Foundation
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (_ uiImage: UIImage?) -> Void
    var onDismiss: () -> Void

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        var onSelect: (_ uiImage: UIImage?) -> Void
        var onDismiss: () -> Void

        init(
            _ presentationMode: Binding<PresentationMode>,
            _ onSelect: @escaping (_ uiImage: UIImage?) -> Void,
            _ onDismiss: @escaping () -> Void
        ) {
            self.onSelect = onSelect
            self.onDismiss = onDismiss
            self._presentationMode = presentationMode
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            let uiImage = ImageController.resizeImage(info[UIImagePickerController.InfoKey.originalImage] as! UIImage)
            self.onSelect(uiImage)
            self.presentationMode.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.onDismiss()
            self.presentationMode.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode, onSelect, onDismiss)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePicker>
    ) {
    }
}
