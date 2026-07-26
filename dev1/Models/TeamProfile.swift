//
//  TeamProfile.swift
//  dev1
//

import Foundation
import SwiftData

/// The club/team this install belongs to, plus who is keeping the books.
///
/// Exactly one of these is expected to exist. It is a SwiftData model rather
/// than `@AppStorage` because it is real domain data — it shows up on the
/// season report the board receives — not a UI preference.
@Model
final class TeamProfile {
    var id: UUID
    var teamName: String
    var organization: String
    var sport: String
    var seasonName: String
    var treasurerName: String
    var treasurerEmail: String
    var createdDate: Date

    init(
        teamName: String,
        organization: String = "",
        sport: String = "Soccer",
        seasonName: String = "",
        treasurerName: String = "",
        treasurerEmail: String = ""
    ) {
        self.id = UUID()
        self.teamName = teamName
        self.organization = organization
        self.sport = sport
        self.seasonName = seasonName
        self.treasurerName = treasurerName
        self.treasurerEmail = treasurerEmail
        self.createdDate = .now
    }

    var displayTitle: String {
        teamName.isEmpty ? "My Team" : teamName
    }

    var displaySubtitle: String {
        [organization, seasonName].filter { !$0.isEmpty }.joined(separator: " \u{00B7} ")
    }

    static let sports = [
        "Soccer", "Basketball", "Baseball", "Softball", "Football",
        "Hockey", "Volleyball", "Lacrosse", "Swimming", "Dance",
        "Cheer", "Track", "Scouts", "Band", "Other"
    ]
}
