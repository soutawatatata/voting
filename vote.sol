pragma solidity >=0.4.22 <0.6.0;

contract Vote {
    struct Candidate {
        string name;
        address addr;
        string manifesto;
        uint voteCount;
    }
    enum Phase { Init, Regist, Vote, Result }
    Phase public phase = Phase.Init;
    address public owner;
    Candidate[] public candidates;
    Candidate public elected;
    mapping(address=>bool) registerd;
    mapping(address=>bool) voted;
    mapping(address=>bytes32) passhash;

    constructor() payable public {
        owner = msg.sender;
    }

    function changePhase(Phase _p) public {
        require(owner == msg.sender, "owner err.");
        phase = _p;
    }

    function registCandidate(string memory _name, string memory _manifesto, bytes32 _passhex) public {
        require(phase == Phase.Regist, "phase err.");
        require(registerd[msg.sender] == false, "already regist err.");
        candidates.push(Candidate({name: _name, addr: msg.sender, manifesto: _manifesto, voteCount: 0}));
        passhash[msg.sender] = keccak256(abi.encode(_passhex));
        registerd[msg.sender] = true;
    }

    function getCandidatesCount() public view returns (uint) {
        return candidates.length;
    }

    function vote(address _addr, bytes32 _passhex) public {
        require(phase == Phase.Vote, "phase err.");
        require(registerd[msg.sender] == true , "no regist address.");
        require(voted[msg.sender] == false, "already voted.");
        require(passhash[msg.sender] == keccak256(abi.encode(_passhex)), "password unmatch.");
        for(uint i = 0; i < candidates.length; i++) {
            if(candidates[i].addr == _addr) {
                candidates[i].voteCount ++;
                voted[msg.sender] = true;
                return;
            }
        }
    }

    function countVote() public {
        require(phase == Phase.Result, "phase err.");
        uint winCount = 0;
        for(uint i = 0; i < candidates.length; i++) {
            if(candidates[i].voteCount > winCount) {
                winCount = candidates[i].voteCount;
                elected = candidates[i];
            }
        }
    }

    function getElectedName() public view returns (string memory) {
        return elected.name;
    }

    function checkPoliticalFundsBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawPoliticalFunds() public {
        require(elected.addr == msg.sender, "withdraw only elected err.");
        msg.sender.transfer(address(this).balance);
    }
}
