// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Decentralised Voting System
 * @dev A transparent, tamper-proof voting smart contract
 * @author Your Name
 */
contract Project {
    
    // Struct to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public admin;
    string public electionName;
    bool public votingActive;
    uint256 public totalVotes;
    uint256 public candidateCount;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not currently active");
        _;
    }
    
    modifier isRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        _;
    }
    
    modifier hasNotVoted() {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        _;
    }
    
    /**
     * @dev Constructor to initialize the contract
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        admin = msg.sender;
        electionName = _electionName;
        votingActive = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    /**
     * @dev Core Function 1: Add candidates to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyAdmin {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(!votingActive, "Cannot add candidates while voting is active");
        
        candidateCount++;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Core Function 2: Cast vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function castVote(uint256 _candidateId) public 
        votingIsActive 
        isRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        
        // Update total votes
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Core Function 3: Get election results
     * @return winnerName Name of the winning candidate
     * @return winnerVotes Number of votes for the winner
     * @return totalVotesCast Total number of votes cast
     */
    function getResults() public view returns (
        string memory winnerName, 
        uint256 winnerVotes, 
        uint256 totalVotesCast
    ) {
        require(candidateCount > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        string memory winner = "";
        
        // Find candidate with maximum votes
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winner = candidates[i].name;
            }
        }
        
        return (winner, maxVotes, totalVotes);
    }
    
    // Additional utility functions
    
    /**
     * @dev Register a voter (only admin can register voters)
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyAdmin {
        require(_voter != address(0), "Invalid voter address");
        require(!voters[_voter].isRegistered, "Voter already registered");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Toggle voting status
     */
    function toggleVoting() public onlyAdmin {
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    /**
     * @dev Get candidate details
     * @param _candidateId ID of the candidate
     */
    function getCandidate(uint256 _candidateId) public view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get total number of registered voters who have voted
     */
    function getTotalVotes() public view returns (uint256) {
        return totalVotes;
    }
    
    /**
     * @dev Check if an address has voting rights and voting status
     */
    function getVoterStatus(address _voter) public view returns (
        bool isRegistered,
        bool hasVoted,
        uint256 votedFor
    ) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
}
