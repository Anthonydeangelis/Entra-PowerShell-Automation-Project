# Synthetic lab fixtures

- `fake-users-25.csv`: retained 25-user input for the CSV provisioning workflow; five users each in IT, Sales, HR, Finance, and Marketing.
- `fake-users.csv`: smaller local practice dataset.
- `user-profile-changes.csv`: alternate profile values for practice, not proof of cloud updates.
- `leavers.csv`: sample usernames for offboarding exercises; no automatic action is attached.

These are fictional lab users and contain no passwords. The showcased creation runbook enables accounts; it does not use the CSV's AccountEnabled field to decide whether to enable them.

## Input versus observed results

The final membership screenshot records HR 5, Sales 6, IT 5, Finance 5, Marketing 4, and Boxing 1. The existing account explains the additional user in Boxing, but the retained CSV alone does not reproduce the Sales/Marketing split. The supplied evidence does not establish which intervening department or membership changes produced that split. The alternate profile fixture is not a record of those changes. Treat the screenshots as observations of the original lab, not expected output from an exact replay of these files.
