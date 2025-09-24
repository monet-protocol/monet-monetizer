// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { SavingsNameable } from "contracts/savings/nameable/SavingsNameable.sol";
import { Savings } from "contracts/savings/Savings.sol";

import "./Base.s.sol";

contract SetSavingRoles is BaseScript {
  address saving = 0x3Baa15BF01A69Cc3Ee81Bb731f1335a7A7344854;

  function run() public broadcast {
    bytes4[] memory guardianSelectors = new bytes4[](2);
    guardianSelectors[0] = Savings.togglePause.selector;
    guardianSelectors[1] = Savings.toggleTrusted.selector;
    accessManager.setTargetFunctionRole(saving, guardianSelectors, Roles.GUARDIAN_ROLE);

    bytes4[] memory keeperSelectors = new bytes4[](1);
    keeperSelectors[0] = Savings.setRate.selector;
    accessManager.setTargetFunctionRole(saving, keeperSelectors, Roles.KEEPER_ROLE);

    bytes4[] memory governorSelectors = new bytes4[](3);
    governorSelectors[0] = SavingsNameable.setNameAndSymbol.selector;
    governorSelectors[1] = Savings.setMaxRate.selector;
    governorSelectors[2] = UUPSUpgradeable.upgradeToAndCall.selector;
    accessManager.setTargetFunctionRole(saving, governorSelectors, Roles.GOVERNOR_ROLE);

    accessManager.grantRole(Roles.USDmo_MINTER_ROLE, address(saving), 0);
  }
}
