// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.28;

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

import { ITokenP } from "contracts/interfaces/ITokenP.sol";
import { AggregatorV3Interface } from "contracts/interfaces/external/chainlink/AggregatorV3Interface.sol";

import { MockAccessControlManager } from "tests/mock/MockAccessControlManager.sol";
import { MockChainlinkOracle } from "tests/mock/MockChainlinkOracle.sol";
import { MockTokenPermit } from "tests/mock/MockTokenPermit.sol";

import { Test } from "contracts/monetizer/configs/Test.sol";
import { LibGetters } from "contracts/monetizer/libraries/LibGetters.sol";
import "contracts/monetizer/Storage.sol";
import "contracts/utils/Constants.sol";
import "contracts/utils/Errors.sol" as Errors;

import { Fixture } from "../Fixture.sol";

contract StablecoinCapTest is Fixture {
  function test_GetStablecoinCap_Init_Success() public {
    assertEq(monetizer.getStablecoinCap(address(eurA)), type(uint256).max);
    assertEq(monetizer.getStablecoinCap(address(eurB)), type(uint256).max);
    assertEq(monetizer.getStablecoinCap(address(eurY)), type(uint256).max);
  }

  function test_RevertWhen_SetStablecoinCap_TooLargeMint() public {
    uint256 amount = 2 ether;
    uint256 stablecoinCap = 1 ether;
    address collateral = address(eurA);

    vm.prank(guardian);
    monetizer.setStablecoinCap(collateral, stablecoinCap);

    deal(collateral, bob, amount);
    startHoax(bob);
    IERC20(collateral).approve(address(monetizer), amount);
    vm.expectRevert(Errors.InvalidSwap.selector);
    startHoax(bob);
    monetizer.swapExactOutput(amount, type(uint256).max, collateral, address(tokenP), bob, block.timestamp * 2);
  }

  function test_RevertWhen_SetStablecoinCap_SlightlyLargeMint() public {
    uint256 amount = 1.0000000000001 ether;
    uint256 stablecoinCap = 1 ether;
    address collateral = address(eurA);

    vm.prank(guardian);
    monetizer.setStablecoinCap(collateral, stablecoinCap);

    deal(collateral, bob, amount);
    startHoax(bob);
    IERC20(collateral).approve(address(monetizer), amount);
    vm.expectRevert(Errors.InvalidSwap.selector);
    startHoax(bob);
    monetizer.swapExactOutput(amount, type(uint256).max, collateral, address(tokenP), bob, block.timestamp * 2);
  }

  function test_SetStablecoinCap_Success() public {
    uint256 amount = 0.99 ether;
    uint256 stablecoinCap = 1 ether;
    address collateral = address(eurA);

    vm.prank(guardian);
    monetizer.setStablecoinCap(collateral, stablecoinCap);

    deal(collateral, bob, amount);
    startHoax(bob);
    IERC20(collateral).approve(address(monetizer), amount);
    startHoax(bob);
    monetizer.swapExactOutput(amount, type(uint256).max, collateral, address(tokenP), bob, block.timestamp * 2);
  }
}
