// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import { IMonetizer } from "contracts/interfaces/IMonetizer.sol";
import { DiamondProxy } from "contracts/monetizer/DiamondProxy.sol";
import "contracts/monetizer/Storage.sol";
import { DiamondCut } from "contracts/monetizer/facets/DiamondCut.sol";
import { DiamondEtherscan } from "contracts/monetizer/facets/DiamondEtherscan.sol";
import { DiamondLoupe } from "contracts/monetizer/facets/DiamondLoupe.sol";
import { Getters } from "contracts/monetizer/facets/Getters.sol";
import { Redeemer } from "contracts/monetizer/facets/Redeemer.sol";
import { RewardHandler } from "contracts/monetizer/facets/RewardHandler.sol";
import { SettersGovernor } from "contracts/monetizer/facets/SettersGovernor.sol";
import { SettersGuardian } from "contracts/monetizer/facets/SettersGuardian.sol";
import { Swapper } from "contracts/monetizer/facets/Swapper.sol";
import "contracts/utils/Errors.sol";

import "./Helper.sol";
import { console } from "@forge-std/console.sol";

abstract contract Monetizer is Helper {
  // Diamond
  IMonetizer monetizer;

  string[] facetNames;
  address[] facetAddressList;

  // @dev Deploys diamond and connects facets
  function deployMonetizer(address _init, bytes memory _calldata) public virtual {
    // Deploy every facet
    facetNames.push("DiamondCut");
    facetAddressList.push(address(new DiamondCut()));

    facetNames.push("DiamondEtherscan");
    facetAddressList.push(address(new DiamondEtherscan()));

    facetNames.push("DiamondLoupe");
    facetAddressList.push(address(new DiamondLoupe()));

    facetNames.push("Getters");
    facetAddressList.push(address(new Getters()));

    facetNames.push("Redeemer");
    facetAddressList.push(address(new Redeemer()));

    facetNames.push("RewardHandler");
    facetAddressList.push(address(new RewardHandler()));

    facetNames.push("SettersGovernor");
    facetAddressList.push(address(new SettersGovernor()));

    facetNames.push("SettersGuardian");
    facetAddressList.push(address(new SettersGuardian()));

    facetNames.push("Swapper");
    facetAddressList.push(address(new Swapper()));

    // Build appropriate payload
    uint256 n = facetNames.length;
    FacetCut[] memory cut = new FacetCut[](n);

    for (uint256 i = 0; i < n; ++i) {
      cut[i] = FacetCut({
        facetAddress: facetAddressList[i],
        action: FacetCutAction.Add,
        functionSelectors: _generateSelectors(facetNames[i])
      });
    }

    // Deploy diamond
    monetizer = IMonetizer(address(new DiamondProxy(cut, _init, _calldata)));
  }

  // @dev Deploys diamond and connects facets
  function deployReplicaMonetizer(
    address _init,
    bytes memory _calldata
  )
    public
    virtual
    returns (IMonetizer _transmuter)
  {
    // Build appropriate payload
    uint256 n = facetNames.length;
    FacetCut[] memory cut = new FacetCut[](n);
    for (uint256 i = 0; i < n; ++i) {
      cut[i] = FacetCut({
        facetAddress: facetAddressList[i],
        action: FacetCutAction.Add,
        functionSelectors: _generateSelectors(facetNames[i])
      });
    }

    // Deploy diamond
    _transmuter = IMonetizer(address(new DiamondProxy(cut, _init, _calldata)));

    return _transmuter;
  }
}
