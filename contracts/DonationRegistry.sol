// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title Decentralized Blood & Organ Donation Registry
/// @notice Donors and recipients can register, and hospitals can match them transparently
contract DonationRegistry {
    enum OrganType { Blood, Kidney, Liver, Heart, Lung }

    struct Donor {
        uint256 id;
        address donorAddress;
        string name;
        string bloodType; // e.g., "A+", "O-"
        OrganType organ;
        bool available;
    }

    struct Recipient {
        uint256 id;
        address recipientAddress;
        string name;
        string bloodType;
        OrganType organNeeded;
        bool matched;
    }

    uint256 public donorCount;
    uint256 public recipientCount;

    mapping(uint256 => Donor) public donors;
    mapping(uint256 => Recipient) public recipients;

    event DonorRegistered(uint256 donorId, address donor, string bloodType, OrganType organ);
    event RecipientRegistered(uint256 recipientId, address recipient, string bloodType, OrganType organNeeded);
    event MatchFound(uint256 donorId, uint256 recipientId);

    /// @notice Register a new donor
    function registerDonor(string memory _name, string memory _bloodType, OrganType _organ) external {
        donorCount++;
        donors[donorCount] = Donor(donorCount, msg.sender, _name, _bloodType, _organ, true);
        emit DonorRegistered(donorCount, msg.sender, _bloodType, _organ);
    }

    /// @notice Register a new recipient
    function registerRecipient(string memory _name, string memory _bloodType, OrganType _organNeeded) external {
        recipientCount++;
        recipients[recipientCount] = Recipient(recipientCount, msg.sender, _name, _bloodType, _organNeeded, false);
        emit RecipientRegistered(recipientCount, msg.sender, _bloodType, _organNeeded);
    }

    /// @notice Match donor to recipient (basic logic: same blood type + same organ)
    function matchDonorRecipient(uint256 _donorId, uint256 _recipientId) external {
        Donor storage donor = donors[_donorId];
        Recipient storage recipient = recipients[_recipientId];

        require(donor.available, "Donor not available");
        require(!recipient.matched, "Recipient already matched");
        require(compareStrings(donor.bloodType, recipient.bloodType), "Blood type mismatch");
        require(donor.organ == recipient.organNeeded, "Organ type mismatch");

        donor.available = false;
        recipient.matched = true;

        emit MatchFound(_donorId, _recipientId);
    }

    /// @notice Utility function for comparing strings (since blood types are stored as strings)
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
