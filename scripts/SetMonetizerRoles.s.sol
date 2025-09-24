// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./Base.s.sol";

import { ISettersGuardian, ISettersGovernor } from "contracts/interfaces/ISetters.sol";
import { IDiamondEtherscan } from "contracts/interfaces/IDiamondEtherscan.sol";

contract SetMonetizerRoles is BaseScript {
  address monetizer = 0xaa2825EBe6E0482c27ab02901EC39c7cDf279151;

  function run() public broadcast {
    bytes4[] memory guardianSelectors = new bytes4[](6);
    guardianSelectors[0] = ISettersGuardian.togglePause.selector;
    guardianSelectors[1] = ISettersGuardian.setFees.selector;
    guardianSelectors[2] = ISettersGuardian.setRedemptionCurveParams.selector;
    guardianSelectors[3] = ISettersGuardian.toggleWhitelist.selector;
    guardianSelectors[4] = ISettersGuardian.setStablecoinCap.selector;
    guardianSelectors[5] = IDiamondEtherscan.setDummyImplementation.selector;
    accessManager.setTargetFunctionRole(monetizer, guardianSelectors, Roles.GUARDIAN_ROLE);

    bytes4[] memory governorSelectors = new bytes4[](11);
    governorSelectors[0] = ISettersGovernor.recoverERC20.selector;
    governorSelectors[1] = ISettersGovernor.setAccessManager.selector;
    governorSelectors[2] = ISettersGovernor.setCollateralManager.selector;
    governorSelectors[3] = ISettersGovernor.changeAllowance.selector;
    governorSelectors[4] = ISettersGovernor.toggleTrusted.selector;
    governorSelectors[5] = ISettersGovernor.addCollateral.selector;
    governorSelectors[6] = ISettersGovernor.adjustStablecoins.selector;
    governorSelectors[7] = ISettersGovernor.revokeCollateral.selector;
    governorSelectors[8] = ISettersGovernor.setOracle.selector;
    governorSelectors[9] = ISettersGovernor.updateOracle.selector;
    governorSelectors[10] = ISettersGovernor.setWhitelistStatus.selector;
    accessManager.setTargetFunctionRole(monetizer, governorSelectors, Roles.GOVERNOR_ROLE);

    accessManager.grantRole(Roles.USDmo_MINTER_ROLE, address(monetizer), 0);
  }
}
