//
//  CountryPickerViewController.swift
//  CountryPickerView
//
//  Created by Kizito Nwose on 18/09/2017.
//  Copyright © 2017 Kizito Nwose. All rights reserved.
//

import UIKit

public class CountryPickerViewController: UITableViewController {

    public var searchController: UISearchController?
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.setupSearchBar(background: UIColor(hex: 0x121212), inputText: UIColor.white, placeholderText: UIColor.white.withAlphaComponent(0.5), image: UIColor.white.withAlphaComponent(0.5))
        searchBar.delegate = self
        return searchBar
    }()

    var searchTerm = ""
    fileprivate var searchResults = [Country]()
    fileprivate var isSearchMode = false
    fileprivate var sectionsTitles = [String]()
    fileprivate var countries = [String: [Country]]()
    fileprivate var hasPreferredSection: Bool {
        return dataSource.preferredCountriesSectionTitle != nil &&
            dataSource.preferredCountries.count > 0
    }
    fileprivate var showOnlyPreferredSection: Bool {
        return dataSource.showOnlyPreferredSection
    }
    public var countryPickerView: CountryPickerView! {
        didSet {
            dataSource = CountryPickerViewDataSourceInternal(view: countryPickerView)
        }
    }
    
    fileprivate var dataSource: CountryPickerViewDataSourceInternal!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(hex: 0x121212)
        prepareTableItems()
        prepareNavItem()
        prepareSearchBar()
    }
   
}

// UI Setup
extension CountryPickerViewController {
    
    func prepareTableItems()  {
        tableView.separatorStyle = .none
        view.backgroundColor = UIColor(hex: 0x121212)
        tableView.backgroundColor = UIColor(hex: 0x121212)
        tableView.backgroundView?.backgroundColor = UIColor(hex: 0x121212)
        if !showOnlyPreferredSection {
            let countriesArray = countryPickerView.usableCountries
            let locale = dataSource.localeForCountryNameInList
            
            var groupedData = Dictionary<String, [Country]>(grouping: countriesArray) {
                let name = $0.localizedName(locale) ?? $0.name
                return String(name.capitalized[name.startIndex])
            }
            groupedData.forEach{ key, value in
                groupedData[key] = value.sorted(by: { (lhs, rhs) -> Bool in
                    return lhs.localizedName(locale) ?? lhs.name < rhs.localizedName(locale) ?? rhs.name
                })
            }
            
            countries = groupedData
            sectionsTitles = groupedData.keys.sorted()
        }
        
        // Add preferred section if data is available
        if hasPreferredSection, let preferredTitle = dataSource.preferredCountriesSectionTitle {
            sectionsTitles.insert(preferredTitle, at: sectionsTitles.startIndex)
            countries[preferredTitle] = dataSource.preferredCountries
        }
        
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexTrackingBackgroundColor = .clear
        tableView.bounces = false
    }
    
    func prepareNavItem() {
        navigationItem.title = dataSource.navigationTitle

        // Add a close button if this is the root view controller
        if navigationController?.viewControllers.count == 1 {
            let closeButton = dataSource.closeButtonNavigationItem
            closeButton.target = self
            closeButton.action = #selector(close)
            navigationItem.leftBarButtonItem = closeButton
        }
    }
    
    func prepareSearchBar() {
        let searchBarPosition = dataSource.searchBarPosition
        if searchBarPosition == .hidden  {
            return
        }

        let countryCodeLabel = UILabel()
        countryCodeLabel.text = "Country code"
        countryCodeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        countryCodeLabel.textAlignment = .center
        countryCodeLabel.textColor = UIColor(hex: 0xFFFFFF, alpha: 0.7)
        let customTableHeaderView = UIView()
        customTableHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: 116)
        customTableHeaderView.addSubview(searchBar)
        customTableHeaderView.addSubview(countryCodeLabel)
        countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        countryCodeLabel.topAnchor.constraint(equalTo: customTableHeaderView.topAnchor, constant: 16).isActive = true
        countryCodeLabel.leftAnchor.constraint(equalTo: customTableHeaderView.leftAnchor, constant: 0).isActive = true
        countryCodeLabel.rightAnchor.constraint(equalTo: customTableHeaderView.rightAnchor, constant: 0).isActive = true
        countryCodeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: countryCodeLabel.bottomAnchor, constant: 16).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        searchBar.leftAnchor.constraint(equalTo: customTableHeaderView.leftAnchor, constant: 12).isActive = true
        searchBar.rightAnchor.constraint(equalTo: customTableHeaderView.rightAnchor, constant: -12).isActive = true
        tableView.tableHeaderView = customTableHeaderView

        self.tableView.setValue(UIColor(hex: 0x121212) , forKey: "tableHeaderBackgroundColor")

    }
    
    @objc private func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableViewDataSource
extension CountryPickerViewController {
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return isSearchMode ? 1 : sectionsTitles.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? searchResults.count : countries[sectionsTitles[section]]!.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: CountryTableViewCell.self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? CountryTableViewCell
            ?? CountryTableViewCell(style: .default, reuseIdentifier: identifier)
        
        
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        var name = country.localizedName(dataSource.localeForCountryNameInList) ?? country.name
        if dataSource.showCountryCodeInList {
            name = "\(name) (\(country.code))"
        }
        if dataSource.showPhoneCodeInList {
            name = "\(name) (\u{202A}\(country.phoneCode)\u{202C})"
        }
        cell.backgroundColor = UIColor(hex: 0x121212)
        cell.flagImageView.image = country.flag
        
//        cell.flgSize = dataSource.cellImageViewSize
        cell.flagImageView.clipsToBounds = true

        cell.flagImageView.layer.cornerRadius = dataSource.cellImageViewCornerRadius
        cell.flagImageView.layer.masksToBounds = true
        
        cell.countryLabel.text = name
        cell.countryLabel.font = dataSource.cellLabelFont
        cell.dialingCodeLabel.font = dataSource.diallingCodeFont
        cell.dialingCodeLabel.text = country.phoneCode
        cell.dialingCodeLabel.textColor = UIColor(white: 1, alpha: 0.5)
        if let color = dataSource.cellLabelColor {
            cell.countryLabel.textColor = color
        }
        cell.accessoryType = country == countryPickerView.selectedCountry &&
            dataSource.showCheckmarkInList ? .checkmark : .none
        cell.separatorInset = .zero
        cell.selectionStyle = .none

        return cell
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return isSearchMode ? nil : sectionsTitles[section]
    }
    
    override public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionsTitles.firstIndex(of: title)!
    }
}

//MARK:- UITableViewDelegate
extension CountryPickerViewController {

    override public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = dataSource.sectionTitleLabelFont
            if let color = dataSource.sectionTitleLabelColor {
                header.textLabel?.textColor = color
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: false)
        let country = isSearchMode ? searchResults[indexPath.row]
            : countries[sectionsTitles[indexPath.section]]![indexPath.row]

        searchController?.isActive = false
        searchController?.dismiss(animated: false, completion: nil)
        
        let completion = {
            self.countryPickerView.selectedCountry = country
        }
        // If this is root, dismiss, else pop
        if navigationController?.viewControllers.count == 1 {
            navigationController?.dismiss(animated: true, completion: completion)
        } else {
            navigationController?.popViewController(animated: true, completion: completion)
        }
        if navigationController == nil {
            self.countryPickerView.selectedCountry = country
        }
    }
}

// MARK:- UISearchResultsUpdating
extension CountryPickerViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        isSearchMode = false
        if let text = searchController.searchBar.text, text.count > 0 {
            isSearchMode = true
            searchResults.removeAll()
            
            var indexArray = [Country]()
            
            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[dataSource.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(text.capitalized[text.startIndex])] {
                indexArray = array
            }

            searchResults.append(contentsOf: indexArray.filter({
                let name = ($0.localizedName(dataSource.localeForCountryNameInList) ?? $0.name).lowercased()
                let code = $0.code.lowercased()
                let query = text.lowercased()
                return name.hasPrefix(query) || (dataSource.showCountryCodeInList && code.hasPrefix(query))
            }))
        }
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension CountryPickerViewController: UISearchBarDelegate {
    private func disableSearchMode() {
        guard isSearchMode else { return }

        isSearchMode = false
        
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTerm = (searchBar.text ?? "").trimmingCharacters(in: .newlines)
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(searchCountries), with: nil, afterDelay: 0.1)
    }
    
    @objc private func searchCountries() {
        isSearchMode = false

        if let text = searchBar.text, !text.isEmpty {
            isSearchMode = true
            searchResults.removeAll()
            
            var indexArray = [Country]()
            
            if showOnlyPreferredSection && hasPreferredSection,
                let array = countries[dataSource.preferredCountriesSectionTitle!] {
                indexArray = array
            } else if let array = countries[String(text.capitalized[text.startIndex])] {
                indexArray = array
            }

            searchResults.append(contentsOf: indexArray.filter({
                let name = ($0.localizedName(dataSource.localeForCountryNameInList) ?? $0.name).lowercased()
                let code = $0.code.lowercased()
                let query = text.lowercased()
                return name.hasPrefix(query) || (dataSource.showCountryCodeInList && code.hasPrefix(query))
            }))
        }
        tableView.reloadData()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clearSearchModeIfNeeded()
    }

    @objc private func clearSearchModeIfNeeded(delay: Bool = false) {
        searchBar.endEditing(true)
        searchTerm = ""
        searchResults.removeAll()
        disableSearchMode()
    }
}

// MARK:- CountryTableViewCell.
class CountryTableViewCell: UITableViewCell {
        
    var dialingCodeLabel: UILabel = UILabel()
    var countryLabel: UILabel = UILabel()
    var flagImageView: UIImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(dialingCodeLabel)
        addSubview(flagImageView)
        addSubview(countryLabel)

        if #available(iOS 9.0, *) {
            dialingCodeLabel.translatesAutoresizingMaskIntoConstraints = false
            flagImageView.translatesAutoresizingMaskIntoConstraints = false
            countryLabel.translatesAutoresizingMaskIntoConstraints = false
            
            flagImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 24).isActive = true
            flagImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            flagImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            flagImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true

            dialingCodeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -24).isActive = true
            dialingCodeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
            
            countryLabel.leftAnchor.constraint(equalTo: flagImageView.rightAnchor, constant: 8).isActive = true
            countryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


// MARK:- An internal implementation of the CountryPickerViewDataSource.
// Returns default options where necessary if the data source is not set.
class CountryPickerViewDataSourceInternal: CountryPickerViewDataSource {
        
    private unowned var view: CountryPickerView
    
    init(view: CountryPickerView) {
        self.view = view
    }
    
    var preferredCountries: [Country] {
        return view.dataSource?.preferredCountries(in: view) ?? preferredCountries(in: view)
    }
    
    var preferredCountriesSectionTitle: String? {
        return view.dataSource?.sectionTitleForPreferredCountries(in: view)
    }
    
    var diallingCodeFont: UIFont {
        return view.dataSource?.diallingCodeFont(in: view) ?? diallingCodeFont(in: view)
    }
    
    var showOnlyPreferredSection: Bool {
        return view.dataSource?.showOnlyPreferredSection(in: view) ?? showOnlyPreferredSection(in: view)
    }
    
    var sectionTitleLabelFont: UIFont {
        return view.dataSource?.sectionTitleLabelFont(in: view) ?? sectionTitleLabelFont(in: view)
    }

    var sectionTitleLabelColor: UIColor? {
        return view.dataSource?.sectionTitleLabelColor(in: view)
    }
    
    var cellLabelFont: UIFont {
        return view.dataSource?.cellLabelFont(in: view) ?? cellLabelFont(in: view)
    }
    
    var cellLabelColor: UIColor? {
        return view.dataSource?.cellLabelColor(in: view)
    }
    
    var cellImageViewSize: CGSize {
        return view.dataSource?.cellImageViewSize(in: view) ?? cellImageViewSize(in: view)
    }
    
    var cellImageViewCornerRadius: CGFloat {
        return view.dataSource?.cellImageViewCornerRadius(in: view) ?? cellImageViewCornerRadius(in: view)
    }
    
    var navigationTitle: String? {
        return view.dataSource?.navigationTitle(in: view)
    }
    
    var closeButtonNavigationItem: UIBarButtonItem {
        guard let button = view.dataSource?.closeButtonNavigationItem(in: view) else {
            return UIBarButtonItem(title: "Close", style: .done, target: nil, action: nil)
        }
        return button
    }
    
    var searchBarPosition: SearchBarPosition {
        return view.dataSource?.searchBarPosition(in: view) ?? searchBarPosition(in: view)
    }
    
    var showPhoneCodeInList: Bool {
        return view.dataSource?.showPhoneCodeInList(in: view) ?? showPhoneCodeInList(in: view)
    }
    
    var showCountryCodeInList: Bool {
        return view.dataSource?.showCountryCodeInList(in: view) ?? showCountryCodeInList(in: view)
    }
    
    var showCheckmarkInList: Bool {
        return view.dataSource?.showCheckmarkInList(in: view) ?? showCheckmarkInList(in: view)
    }
    
    var localeForCountryNameInList: Locale {
        return view.dataSource?.localeForCountryNameInList(in: view) ?? localeForCountryNameInList(in: view)
    }
    
    var excludedCountries: [Country] {
        return view.dataSource?.excludedCountries(in: view) ?? excludedCountries(in: view)
    }
}

extension UISearchBar {

    func setupSearchBar(background: UIColor = .white, inputText: UIColor = .black, placeholderText: UIColor = .gray, image: UIColor = .black) {

        self.searchBarStyle = .minimal

        self.barStyle = .default

        // IOS 12 and lower:
        for view in self.subviews {

            for subview in view.subviews {
                if subview is UITextField {
                    if let textField: UITextField = subview as? UITextField {

                        // Background Color
                        textField.backgroundColor = background

                        //   Text Color
                        textField.textColor = inputText

                        //  Placeholder Color
                        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderText])

                        //  Default Image Color
                        if let leftView = textField.leftView as? UIImageView {
                            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                            leftView.tintColor = image
                        }

                        let backgroundView = textField.subviews.first
                        backgroundView?.backgroundColor = background
                        backgroundView?.layer.cornerRadius = 10.5
                        backgroundView?.layer.masksToBounds = true

                    }
                }
            }

        }

        // IOS 13 only:
        if let textField = self.value(forKey: "searchField") as? UITextField {

            // Background Color
            textField.backgroundColor = background

            //   Text Color
            textField.textColor = inputText

            //  Placeholder Color
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderText])

            //  Default Image Color
            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = image
            }

        }

    }

}


