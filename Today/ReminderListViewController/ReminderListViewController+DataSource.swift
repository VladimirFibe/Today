import UIKit

extension ReminderListViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>

    var reminderCompletedValue: String {
        NSLocalizedString("Completed", comment: "Reminder completed value")
    }

    var reminderNotCompletedValue: String {
        NSLocalizedString("Not completed", comment: "Reminder not completed value")
    }

    func updateSnapshot(reloading ids: [Reminder.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(reminders.map { $0.id })
        if !ids.isEmpty { snapshot.reloadItems(ids)}
        dataSource.apply(snapshot)
    }
    func cellRegistrationHandler(
        cell: UICollectionViewListCell,
        indexPath: IndexPath,
        id: Reminder.ID
    ) {
        let reminder = reminder(withId: id)
        var contentConfigureation = cell.defaultContentConfiguration()
        contentConfigureation.text = reminder.title
        contentConfigureation.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfigureation.secondaryTextProperties.font = .preferredFont(forTextStyle: .caption1)
        cell.contentConfiguration = contentConfigureation
        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
        doneButtonConfiguration.tintColor = .todayListCellDoneButtonTint
        cell.accessibilityCustomActions = [doneButtonAccessibilityAction(for: reminder)]
        cell.accessibilityValue = reminder.isComplete ? reminderCompletedValue : reminderNotCompletedValue
        cell.accessories = [
            .customView(configuration: doneButtonConfiguration),
            .disclosureIndicator(displayed: .always)
        ]
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .todayListCellBackground
        cell.backgroundConfiguration = backgroundConfiguration
    }

    private func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(withId: id)
        return reminders[index]
    }

    func pushDetailViewForReminder(withId id: Reminder.ID) {
        let reminder = reminder(withId: id)

        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.updateReminder(reminder)
            self?.updateSnapshot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }

    private func updateReminder(_ reminder: Reminder) {
        let index = reminders.indexOfReminder(withId: reminder.id)
        reminders[index] = reminder
    }

    func completeReminder(withId id: Reminder.ID) {
        var reminder = reminder(withId: id)
        reminder.isComplete.toggle()
        updateReminder(reminder)
        updateSnapshot(reloading: [id])
    }

    private func doneButtonAccessibilityAction(
        for reminder: Reminder
    ) -> UIAccessibilityCustomAction {
        let name = NSLocalizedString(
            "Toggle completion",
            comment: "Reminder done button accessiblity label"
        )
        let action = UIAccessibilityCustomAction(name: name) { [weak self] action in
            self?.completeReminder(withId: reminder.id)
            return true
        }
        return action
    }

    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
        let symbolConfiguration = UIImage.SymbolConfiguration(
            textStyle: .title1
        )
        let image = UIImage(
            systemName: symbolName,
            withConfiguration: symbolConfiguration
        )
        let button = ReminderDonButton()
        button.id = reminder.id
        button.addTarget(self, action: #selector(didPressDoneButton), for: .primaryActionTriggered)
        button.setImage(image, for: .normal)
        return UICellAccessory.CustomViewConfiguration(
            customView: button,
            placement: .leading(displayed: .always)
        )
    }
}
