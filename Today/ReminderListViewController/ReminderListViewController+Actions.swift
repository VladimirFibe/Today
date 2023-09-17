import UIKit

extension ReminderListViewController {
    @objc func didPressDoneButton(_ sender: ReminderDonButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id)
    }
}
