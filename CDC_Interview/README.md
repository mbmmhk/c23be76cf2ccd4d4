# Background
This project is in a partially completed state, originally initiated by a junior developer. We’d like your help to complete it and address some outstanding issues. This project uses **SwiftUI**.

## Aim
We want to learn more about you, including your coding style, preferred design patterns, codebase management, Git commit practices, and testing habits. Through this sample project, we aim to gain insight into these areas before proceeding to the next stage.

## What This App Does
1. Fetches and displays a list of supported cryptocurrencies along with their corresponding prices.  
   1.1. The v1 API call is simulated by reading the `usdPrices.json` file.
2. Allows users to search for a specific token using the search text field at the top.
3. The app has a settings page to toggle feature flags.

## Before the Interview
Please take some time to review the code and practices implemented in the project.

## What to Do
1. Share with us any potential issues or improvements you have identified, as well as any other thoughts on the project.
2. Implement functionality to display the EUR price in addition to the USD price in the UI.  
   2.1. The ability to show the EUR price is controlled by the feature flag `Support EUR`, located in the Settings page (`SettingViewController`).  
   2.2. When the flag is **off**, the existing behavior should remain unchanged.  
   2.3. When the flag is **on**, simulate the v2 API call by reading from the `allPrices.json` file:  
      - 2.3.1. When the EUR price is available, append it after the USD price in the list, e.g., `USD: 123.45 EUR: 678.91`.
3. Implement navigation to a detail view when a user taps on an item in the list. The detail view should be a new SwiftUI view that displays:
   - The name of the selected token.
   - The price of the token. The format should reflect the "Support EUR" feature flag:
     - Flag off: `USD: $123.45`
     - Flag on: `USD: $123.45 EUR: 234.56` (if EUR is available)
   
     A simple illustration:

        | < Back --- BTC --- |
        |--------------------|
        | USD: 29,130.52     |
        | EUR: 27,084.11     |

4. Fix the search functionality, which currently does not return results after text input.

## Remarks
- We encourage you to make commits as you work on the tasks, just as you would in your day-to-day work. This helps us understand your git practices.
- Feel free to make or suggest other changes you see fit. This could include, but is not limited to, improving code practices, fixing any bugs you find, or refactoring for better architecture.
- Please supplement your submission with a summary to elaborate on the changes you've made or to explain the rationale behind your implementation decisions.
