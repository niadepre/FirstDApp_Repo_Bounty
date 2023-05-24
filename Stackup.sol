// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract StackUp {
    enum playerQuestStatus {
        NOT_JOINED,
        JOINED,
        SUBMITTED
    }

    struct Quest {
        uint256 questId;
        uint256 numberOfPlayers;
        string title;
        uint8 reward;
        uint256 numberOfRewards;
        uint256 startTime;  //this will hold the quest start time
        uint256 endTime;  //this will hold the quest end time
    }

    address public admin;
    uint256 public nextQuestId;
    mapping(uint256 => Quest) public quests;
    mapping(address => mapping(uint256 => playerQuestStatus))
        public playerQuestStatuses;

    constructor() {
        admin = msg.sender;
    }

    function createQuest(
        string calldata title_,
        uint8 reward_,
        uint256 numberOfRewards_,
        uint256 startTime_,  //function parameter to accept the Quest Start Time when the quest should start
        uint256 endTime_  //function parameter to accept the Quest End Time when the quest should end
    ) external {
        require(msg.sender == admin, "Only the admin can create quests");
        require(startTime_ < endTime_, "End Time must be after Start Time");  //Here i check to make sure that the user enters an End time not earlier than start Time.
        quests[nextQuestId].questId = nextQuestId;
        quests[nextQuestId].title = title_;
        quests[nextQuestId].reward = reward_;
        quests[nextQuestId].numberOfRewards = numberOfRewards_;
        quests[nextQuestId].startTime = block.timestamp + (startTime_ * 1 days);  //here i convert the Start time to a timestamp readable by compiler
        quests[nextQuestId].endTime = block.timestamp + (endTime_ * 1 days); ////here i convert the End time to a timestamp readable by compiler
        nextQuestId++;
    }

    function joinQuest(uint256 questId) external questExists(questId) {
        require(quests[nextQuestId].startTime >= block.timestamp, "This quest has not started"); //this code will check if the quest has started before users can be allowed to join
        require(quests[nextQuestId].endTime <= block.timestamp, "This quest has ended"); //this code will check ifthe quest is still running or it has ended
        require(
            playerQuestStatuses[msg.sender][questId] ==
                playerQuestStatus.NOT_JOINED,
            "Player has already joined/submitted this quest"
        );
        playerQuestStatuses[msg.sender][questId] = playerQuestStatus.JOINED;

        Quest storage thisQuest = quests[questId];
        thisQuest.numberOfPlayers++;
    }

    function submitQuest(uint256 questId) external questExists(questId) {
        require(quests[nextQuestId].endTime <= block.timestamp, "This quest has ended"); //checks to make sure quest is still open and have not ended.
        require(
            playerQuestStatuses[msg.sender][questId] ==
                playerQuestStatus.JOINED,
            "Player must first join the quest"
        );
        playerQuestStatuses[msg.sender][questId] = playerQuestStatus.SUBMITTED;
    }

    modifier questExists(uint256 questId) {
        require(quests[questId].reward != 0, "Quest does not exist");
        _;
    }
}
