// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Hassan is ERC20, ERC20Permit {
    constructor() ERC20("Hassan", "HSN") ERC20Permit("Hassan") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}


contract AuctionHouse is Ownable, ReentrancyGuard {

    
    struct Auction {
        address seller;         // who listed the item
        string  item;           // item description or ID
        uint256 startingPrice;  // in wei
        uint256 endTime;        // timestamp when auction ends
        address highestBidder;  // current winner
        uint256 highestBid;     // current top bid (in wei)
        bool    active;         // true until finalized or canceled
        bool    cancelled;      // true if seller canceled
        bool    ended;          // true after finalizeAuction()
    }

    constructor(uint256 _platformFeeBps) Ownable(msg.sender) {
         require(_platformFeeBps <= 1000, "Fee > 10%");
         platformFeeBps = _platformFeeBps;
    }

    uint256 public auctionCount;
    mapping(uint256 => Auction) public auctions;
    // bids[auctionId][bidder] = total wei they've bid
    mapping(uint256 => mapping(address => uint256)) public bids;

    /// @dev Fee in basis points (e.g. 250 = 2.5%)
    uint256 public platformFeeBps;
    uint256 public collectedFees;
    /// @dev If a bid comes in with < timeBuffer seconds remaining, extend by timeBuffer
    uint256 public immutable timeBuffer = 5 minutes;

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        string  item,
        uint256 startingPrice,
        uint256 endTime
    );
    event AuctionBid(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount,
        uint256 newEndTime
    );
    event BidWithdrawn(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount
    );
    event AuctionFinalized(
        uint256 indexed auctionId,
        address winner,
        uint256 amount
    );
    event AuctionCancelled(uint256 indexed auctionId);

    /// @notice Seller lists a new item
    /// @param item A short description or token ID
    /// @param startingPrice Minimum bid in wei
    /// @param duration How long (in seconds) the auction runs
    function createAuction(
        string calldata item,
        uint256 startingPrice,
        uint256 duration
    ) external {
        require(startingPrice > 0, "Price > 0");
        require(duration >= 1 minutes, "Duration >= 1m");

        auctionCount++;
        uint256 endAt = block.timestamp + duration;

        auctions[auctionCount] = Auction({
            seller:       msg.sender,
            item:         item,
            startingPrice:startingPrice,
            endTime:      endAt,
            highestBidder:address(0),
            highestBid:   0,
            active:       true,
            cancelled:    false,
            ended:        false
        });

        emit AuctionCreated(auctionCount, msg.sender, item, startingPrice, endAt);
    }

    /// @notice Place or top‐up a bid on an active auction
    function bid(uint256 auctionId) external payable nonReentrant {
        Auction storage a = auctions[auctionId];
        require(a.active && !a.cancelled, "Not active");
        require(block.timestamp < a.endTime, "Already ended");

        uint256 totalBid = bids[auctionId][msg.sender] + msg.value;
        uint256 minRequired = a.highestBid == 0
            ? a.startingPrice
            : a.highestBid + 1 wei;
        require(totalBid >= minRequired, "Bid too low");

        bids[auctionId][msg.sender] = totalBid;
        a.highestBid = totalBid;
        a.highestBidder = msg.sender;

        // bonus: extend if within timeBuffer
        if (a.endTime - block.timestamp < timeBuffer) {
            a.endTime = block.timestamp + timeBuffer;
        }

        emit AuctionBid(auctionId, msg.sender, totalBid, a.endTime);
    }

    /// @notice Withdraw non-winning bids after auction ends or is cancelled
    function withdraw(uint256 auctionId) external nonReentrant {
        Auction storage a = auctions[auctionId];
        require(a.ended || a.cancelled, "Not over");
        require(msg.sender != a.highestBidder, "Winner can't withdraw");

        uint256 bal = bids[auctionId][msg.sender];
        require(bal > 0, "Nothing to withdraw");

        bids[auctionId][msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit BidWithdrawn(auctionId, msg.sender, bal);
    }

    /// @notice Finalize an auction (anyone can call after endTime)
    function finalizeAuction(uint256 auctionId) external nonReentrant {
        Auction storage a = auctions[auctionId];
        require(a.active && !a.cancelled, "Cannot finalize");
        require(block.timestamp >= a.endTime, "Too early");

        a.active = false;
        a.ended  = true;

        if (a.highestBidder != address(0)) {
            // calculate and collect fee
            uint256 fee = (a.highestBid * platformFeeBps) / 10_000;
            uint256 sellerProceeds = a.highestBid - fee;
            collectedFees += fee;

            // send ETH to seller
            payable(a.seller).transfer(sellerProceeds);

            // NOTE: item transfer logic (e.g. ERC‑721) goes here, if needed
        }

        emit AuctionFinalized(auctionId, a.highestBidder, a.highestBid);
    }

    /// @notice Seller can cancel if no bids have been placed
    function cancelAuction(uint256 auctionId) external {
        Auction storage a = auctions[auctionId];
        require(a.active && !a.cancelled, "Not active");
        require(msg.sender == a.seller, "Only seller");
        require(a.highestBid == 0, "Has bids");

        a.active    = false;
        a.cancelled = true;
        emit AuctionCancelled(auctionId);
    }

    /// @notice Owner can withdraw collected platform fees
    function withdrawFees() external onlyOwner {
        require(collectedFees > 0, "No fees");
        uint256 amt = collectedFees;
        collectedFees = 0;
        payable(owner()).transfer(amt);
    }

    /// @notice Fallback to accept ETH
    receive() external payable {}
}
