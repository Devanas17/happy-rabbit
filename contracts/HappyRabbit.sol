// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import "hardhat/console.sol";

// Custom Errors

contract HappyRabbit is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // STRUCT
    struct RabbitAttributes {
        uint256 rabbitIndex;
        string imageURI;
        uint256 happiness;
        uint256 hunger;
        uint256 enrichment;
        uint256 lastChecked;
    }

    // storage variable
    string SVGBase =
        "data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHdpZHRoPScxMDAlJyBoZWlnaHQ9JzEwMCUnIHZpZXdCb3g9JzAgMCA4MDAgODAwJz48cmVjdCBmaWxsPScjZmZmZmZmJyB3aWR0aD0nODAwJyBoZWlnaHQ9JzgwMCcvPjxkZWZzPjxyYWRpYWxHcmFkaWVudCBpZD0nYScgY3g9JzQwMCcgY3k9JzQwMCcgcj0nNTAuMSUnIGdyYWRpZW50VW5pdHM9J3VzZXJTcGFjZU9uVXNlJz48c3RvcCAgb2Zmc2V0PScwJyBzdG9wLWNvbG9yPScjZmZmZmZmJy8+PHN0b3AgIG9mZnNldD0nMScgc3RvcC1jb2xvcj0nIzBFRicvPjwvcmFkaWFsR3JhZGllbnQ+PHJhZGlhbEdyYWRpZW50IGlkPSdiJyBjeD0nNDAwJyBjeT0nNDAwJyByPSc1MC40JScgZ3JhZGllbnRVbml0cz0ndXNlclNwYWNlT25Vc2UnPjxzdG9wICBvZmZzZXQ9JzAnIHN0b3AtY29sb3I9JyNmZmZmZmYnLz48c3RvcCAgb2Zmc2V0PScxJyBzdG9wLWNvbG9yPScjMEZGJy8+PC9yYWRpYWxHcmFkaWVudD48L2RlZnM+PHJlY3QgZmlsbD0ndXJsKCNhKScgd2lkdGg9JzgwMCcgaGVpZ2h0PSc4MDAnLz48ZyBmaWxsLW9wYWNpdHk9JzAuNSc+PHBhdGggZmlsbD0ndXJsKCNiKScgZD0nTTk5OC43IDQzOS4yYzEuNy0yNi41IDEuNy01Mi43IDAuMS03OC41TDQwMSAzOTkuOWMwIDAgMC0wLjEgMC0wLjFsNTg3LjYtMTE2LjljLTUuMS0yNS45LTExLjktNTEuMi0yMC4zLTc1LjhMNDAwLjkgMzk5LjdjMCAwIDAtMC4xIDAtMC4xbDUzNy4zLTI2NWMtMTEuNi0yMy41LTI0LjgtNDYuMi0zOS4zLTY3LjlMNDAwLjggMzk5LjVjMCAwIDAtMC4xLTAuMS0wLjFsNDUwLjQtMzk1Yy0xNy4zLTE5LjctMzUuOC0zOC4yLTU1LjUtNTUuNWwtMzk1IDQ1MC40YzAgMC0wLjEgMC0wLjEtMC4xTDczMy40LTk5Yy0yMS43LTE0LjUtNDQuNC0yNy42LTY4LTM5LjNsLTI2NSA1MzcuNGMwIDAtMC4xIDAtMC4xIDBsMTkyLjYtNTY3LjRjLTI0LjYtOC4zLTQ5LjktMTUuMS03NS44LTIwLjJMNDAwLjIgMzk5YzAgMC0wLjEgMC0wLjEgMGwzOS4yLTU5Ny43Yy0yNi41LTEuNy01Mi43LTEuNy03OC41LTAuMUwzOTkuOSAzOTljMCAwLTAuMSAwLTAuMSAwTDI4Mi45LTE4OC42Yy0yNS45IDUuMS01MS4yIDExLjktNzUuOCAyMC4zbDE5Mi42IDU2Ny40YzAgMC0wLjEgMC0wLjEgMGwtMjY1LTUzNy4zYy0yMy41IDExLjYtNDYuMiAyNC44LTY3LjkgMzkuM2wzMzIuOCA0OTguMWMwIDAtMC4xIDAtMC4xIDAuMUw0LjQtNTEuMUMtMTUuMy0zMy45LTMzLjgtMTUuMy01MS4xIDQuNGw0NTAuNCAzOTVjMCAwIDAgMC4xLTAuMSAwLjFMLTk5IDY2LjZjLTE0LjUgMjEuNy0yNy42IDQ0LjQtMzkuMyA2OGw1MzcuNCAyNjVjMCAwIDAgMC4xIDAgMC4xbC01NjcuNC0xOTIuNmMtOC4zIDI0LjYtMTUuMSA0OS45LTIwLjIgNzUuOEwzOTkgMzk5LjhjMCAwIDAgMC4xIDAgMC4xbC01OTcuNy0zOS4yYy0xLjcgMjYuNS0xLjcgNTIuNy0wLjEgNzguNUwzOTkgNDAwLjFjMCAwIDAgMC4xIDAgMC4xbC01ODcuNiAxMTYuOWM1LjEgMjUuOSAxMS45IDUxLjIgMjAuMyA3NS44bDU2Ny40LTE5Mi42YzAgMCAwIDAuMSAwIDAuMWwtNTM3LjMgMjY1YzExLjYgMjMuNSAyNC44IDQ2LjIgMzkuMyA2Ny45bDQ5OC4xLTMzMi44YzAgMCAwIDAuMSAwLjEgMC4xbC00NTAuNCAzOTVjMTcuMyAxOS43IDM1LjggMzguMiA1NS41IDU1LjVsMzk1LTQ1MC40YzAgMCAwLjEgMCAwLjEgMC4xTDY2LjYgODk5YzIxLjcgMTQuNSA0NC40IDI3LjYgNjggMzkuM2wyNjUtNTM3LjRjMCAwIDAuMSAwIDAuMSAwTDIwNy4xIDk2OC4zYzI0LjYgOC4zIDQ5LjkgMTUuMSA3NS44IDIwLjJMMzk5LjggNDAxYzAgMCAwLjEgMCAwLjEgMGwtMzkuMiA1OTcuN2MyNi41IDEuNyA1Mi43IDEuNyA3OC41IDAuMUw0MDAuMSA0MDFjMCAwIDAuMSAwIDAuMSAwbDExNi45IDU4Ny42YzI1LjktNS4xIDUxLjItMTEuOSA3NS44LTIwLjNMNDAwLjMgNDAwLjljMCAwIDAuMSAwIDAuMSAwbDI2NSA1MzcuM2MyMy41LTExLjYgNDYuMi0yNC44IDY3LjktMzkuM0w0MDAuNSA0MDAuOGMwIDAgMC4xIDAgMC4xLTAuMWwzOTUgNDUwLjRjMTkuNy0xNy4zIDM4LjItMzUuOCA1NS41LTU1LjVsLTQ1MC40LTM5NWMwIDAgMC0wLjEgMC4xLTAuMUw4OTkgNzMzLjRjMTQuNS0yMS43IDI3LjYtNDQuNCAzOS4zLTY4bC01MzcuNC0yNjVjMCAwIDAtMC4xIDAtMC4xbDU2Ny40IDE5Mi42YzguMy0yNC42IDE1LjEtNDkuOSAyMC4yLTc1LjhMNDAxIDQwMC4yYzAgMCAwLTAuMSAwLTAuMUw5OTguNyA0MzkuMnonLz48L2c+PHRleHQgeD0nNTAlJyB5PSc1MCUnIGNsYXNzPSdiYXNlJyBkb21pbmFudC1iYXNlbGluZT0nbWlkZGxlJyB0ZXh0LWFuY2hvcj0nbWlkZGxlJyBmb250LXNpemU9JzhlbSc+8J+";

    string[] emojiBase64 = [
        "kqTwvdGV4dD48L3N2Zz4=",
        "YgTwvdGV4dD48L3N2Zz4=",
        "YkDwvdGV4dD48L3N2Zz4=",
        "YoTwvdGV4dD48L3N2Zz4=",
        "SgDwvdGV4dD48L3N2Zz4="
    ];

    // Mapping
    mapping(uint256 => RabbitAttributes) public rabbitHolderAttributes;

    // A mapping from an address => the NFTs tokenId.
    mapping(address => uint256) public rabbitHolders;

    constructor() ERC721("HappyRabbit", "HRB") {
        _tokenIdCounter.increment();
    }

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        string memory finalSVG = string(
            abi.encodePacked(SVGBase, emojiBase64[0])
        );

        rabbitHolderAttributes[tokenId] = RabbitAttributes({
            rabbitIndex: tokenId,
            imageURI: finalSVG,
            happiness: 100,
            hunger: 100,
            enrichment: 100,
            lastChecked: block.timestamp
        });

        rabbitHolders[msg.sender] = tokenId;
        console.log("Minted NFT w/ tokenId %s and characterIndex %s");
        //
        _setTokenURI(tokenId, tokenURI(tokenId));
        _tokenIdCounter.increment();
    }

    function rabbitStats(
        uint256 _tokenId
    ) public view returns (uint256, uint256, uint256, uint256, string memory) {
        return (
            rabbitHolderAttributes[_tokenId].happiness,
            rabbitHolderAttributes[_tokenId].hunger,
            rabbitHolderAttributes[_tokenId].enrichment,
            rabbitHolderAttributes[_tokenId].lastChecked,
            rabbitHolderAttributes[_tokenId].imageURI
        );
    }

    function myRabbit()
        public
        view
        returns (uint256, uint256, uint256, uint256, string memory)
    {
        return rabbitStats(rabbitHolders[msg.sender]);
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        RabbitAttributes memory rabbitAttributes = rabbitHolderAttributes[
            tokenId
        ];

        string memory strHappiness = Strings.toString(
            rabbitAttributes.happiness
        );
        string memory strHunger = Strings.toString(rabbitAttributes.hunger);
        string memory strEnrichment = Strings.toString(
            rabbitAttributes.enrichment
        );

        string memory json = string(
            abi.encodePacked(
                '{"name": "Happy Bunny",',
                '"description": "Always make me happy!",',
                '"image": "',
                rabbitAttributes.imageURI,
                '",',
                '"traits": [',
                '{"trait_type": "Hunger","value": ',
                strHunger,
                '}, {"trait_type": "Enrichment", "value": ',
                strEnrichment,
                '}, {"trait_type": "Happiness","value": ',
                strHappiness,
                "}]",
                "}"
            )
        );
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            tokenId,
            msg.sender
        );

        string memory output = string(abi.encodePacked(json));
        return output;
    }
}
// QmZ67ajgKC6ipqu9KAgu56utk4dmC7Fo4zJm1a12XxzvrN
