// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol";

contract Election {

    bool verif;

    //user for login only
    struct user
    {
        string logaddr;
        string passwordReal;
    }
    //candidate
    struct Candidate{
        uint id;
        string name; 
    }
    //Ballot data
    struct Ballot{
        string addr;
        uint votefor;
        uint condition;
    }
    struct BallotVID{
        string addr;
        uint votefor;
    }
    struct BallotaddrINT{
        string addr;
    }
    //events
    event userCreated(
      string logaddr,
      string passwordReal
    );

    constructor() {
        addCandidate("Cat");
        addCandidate("Dog");
    }

    uint public userCount = 0;
    mapping (string => user) public usersList;
    mapping (uint => Candidate) public candidates;
    mapping (uint => Ballot) public ballots;
    mapping (uint => BallotVID) public ballotvids;
    mapping (uint => BallotaddrINT) public Ballotaddrints;
    //mapping (uint => FakeVoter) public fakevoters;
    mapping (address => bool) public voter;
    uint public candidatecount;
    uint public votercount = 0;

    //signature verifier
    function verifySignature(
        bytes32 messageHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (bool) {
        // Recover the public key from the signature
        address recoveredSigner = ECDSA.recover(messageHash, v, r, s);

        // Check if the recovered signer matches the provided signer
        return recoveredSigner == address(0x2c7536E3605D9C16a7a3D7b1898e529396a65c23);
    }

    //create user for login function
    function createUser(bytes32 _messageHash,
                        uint8 _v,
                        bytes32 _r,
                        bytes32 _s,
                        string memory _logaddr,
                        string memory _passwordReal) public
    {     
        bool verify = verifySignature(_messageHash, _v, _r, _s);
        require (verify);
        userCount++;
        usersList[_logaddr] = user(_logaddr, _passwordReal);
        emit userCreated(_logaddr, _passwordReal);
    }

    //add candidate funcion
    function addCandidate (string memory _name) public {
        candidates[candidatecount] = Candidate(candidatecount, _name);
        candidatecount++;
    }

    //cast a vote function
    function vote ( bytes32 _messageHash,
                        uint8 _v,
                        bytes32 _r,
                        bytes32 _s,
                        uint _votecondition, //_votecondition
                        uint _candidateid, 
                        uint _vid, 
                        string memory _voteraddr,
                        uint _AddressInt) public 
    {
        bool verify = verifySignature(_messageHash, _v, _r, _s);
        require (verify);
        require (!voter[msg.sender]);

            votercount++;
            ballots[votercount] = Ballot(_voteraddr, _candidateid, _votecondition);
            ballotvids[_vid] = BallotVID(_voteraddr, _candidateid);
            Ballotaddrints[_AddressInt] = BallotaddrINT(_voteraddr);
        
    }

    //login
    function getaddr (string memory _logaddr) public view returns (string memory) {
        return (usersList[_logaddr].logaddr);
    }
    function getpasswordReal (string memory _logaddr) public view returns (string memory) {
        return (usersList[_logaddr].passwordReal);
    }

    //vote

    //candidates
    function getid (uint _candidateid) public view returns (uint) {
        return (candidates[_candidateid].id);
    }
    function getname (uint _candidateid) public view returns (string memory) {
        return (candidates[_candidateid].name);
    }

    //search Ballot
    function getcondition (uint _votercount) public view returns (uint) {
        return (ballots[_votercount].condition);
    }
    function getvoter (uint _votercount) public view returns (string memory) { 
        return (ballots[_votercount].addr);
    }
    function getvotefor (uint _votercount) public view returns (uint) {
        return (ballots[_votercount].votefor);
    }

    //search BallotVID
    function getvotervid (uint _vid) public view returns (string memory) {
        return (ballotvids[_vid].addr);
    }
    function getvoteforvid (uint _vid) public view returns (uint) {
        return (ballotvids[_vid].votefor);
    }

    //search Ballotaddrints
    function getvoteforint (uint _AddressInt) public view returns (string memory) {
        return (Ballotaddrints[_AddressInt].addr);
    }
}