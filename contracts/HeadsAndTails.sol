// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.26;

contract HeadsAndTails {
    address payable public owner;

    enum Side { Heads, Tails, None }

    struct Player {
        string _name;
        address _address;
        uint256 betAmount;
    }
    mapping(Side => Player) public information;

    bool public gameStarted;
    Side public droppedSide = Side.None;
    Player public winner;    

    event BetPlaced(address indexed player, uint256 amount, Side side, string name);
    event WinnerReady(Player winner);
    event FundsDistributed(address winner, uint256 winnerAmount, address owner, uint256 ownerAmount);


    constructor() {
        owner = payable(0xC9339339B60AC256819aE999BcAeD2e15E2fdA63);
    }

    modifier isName(string memory _name) {
        require(bytes(_name).length > 0, "You didn't enter a name!");
        _;
    }

    modifier uniqueSide(Side side) {
        require(information[side]._address == address(0) || (information[side]._address != address(0) && bytes(winner._name).length > 0), "There is already a bet on this side of the coin!");
        _;
    }

    modifier equalValue(uint256 requiredValue) {
        require(msg.value == requiredValue, "Incorrect bet amount!");
        _;
    }


    function recordBet(string memory _name, Side side) internal {
        information[side] = Player(_name, msg.sender, msg.value);
        emit BetPlaced(msg.sender, msg.value, side, _name);
    }

    function getRandomZeroOrOne() public view returns (uint8) {
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(block.prevrandao, block.timestamp, msg.sender)
            )
        );
        return uint8(randomHash % 2);
    }

    function play() internal {
        Side winningSide = Side(getRandomZeroOrOne());
        droppedSide = winningSide;
        winner = information[winningSide];        
        emit WinnerReady(winner);

        uint256 totalPot = address(this).balance;
        uint256 winnerShare = (totalPot * 90) / 100;
        uint256 ownerShare = totalPot - winnerShare;

        payable(winner._address).transfer(winnerShare);
        owner.transfer(ownerShare);

        emit FundsDistributed(winner._address, winnerShare, owner, ownerShare);
        gameStarted = false;
    }

    function placeBet(string memory _name, Side side) public payable isName(_name) uniqueSide(side) equalValue(0.04 ether) {
        if (!gameStarted) {
            winner = Player("", address(0), 0);
            information[Side.Heads] = Player("", address(0), 0);
            information[Side.Tails] = Player("", address(0), 0);
            droppedSide = Side.None;
            recordBet(_name, side);
            gameStarted = true;          
        } else {
            recordBet(_name, side);
            play();
        }
    }

    function getPlayer(Side side) public view returns(Player memory) {
        return information[side];
    }
}
