# Monet - Monetizer

## Summary

**Monetizer is an authorized fork of Angle's Transmuter which is an autonomous and modular price stability module for
decentralized stablecoin protocols.**

- It is conceived as a basket of different assets (normally stablecoins) backing a stablecoin and comes with guarantees
  on the maximum exposure the stablecoin can have to each asset in the basket.
- A stablecoin issued through the Monetizer system can be minted at oracle value from any of the assets with adaptive
  fees, and it can be burnt for any of the assets in the backing with variable fees as well. It can also be redeemed at
  any time against a proportional amount of each asset in the backing.

Monetizer is compatible with other common mechanisms often used to issue stablecoins like collateralized-debt position
models.

## Architecture

The Monetizer system relies on a [diamond proxy pattern](https://eips.ethereum.org/EIPS/eip-2535). There is as such only
one main contract (the `Monetizer` contract) which delegates calls to different facets each with their own
implementation. The main facets of the system are:

- the [`Swapper`](./contracts/monetizer/facets/Swapper.sol) facet with the logic associated to the mint and burn
  functionalities of the system
- the [`Redeemer`](./contracts/monetizer/facets/Redeemer.sol) facet for redemptions
- the [`Getters`](./contracts/monetizer/facets/Getters.sol) facet with external getters for UIs and contracts built on
  top of `Monetizer`
- the [`SettersGovernor`](./contracts/monetizer/facets/SettersGovernor.sol) facet protocols' governance can use to
  update system parameters.
- the [`SettersGuardian`](./contracts/monetizer/facets/SettersGuardian.sol) facet protocols' guardian can use to update
  system parameters.

The storage parameters of the system are defined in the [`Storage`](./contracts/monetizer/Storage.sol) file.

The Monetizer system can come with optional [ERC4626](https://eips.ethereum.org/EIPS/eip-4626)
[savings contracts](./contracts/savings/) which can be used to distribute a yield to the holders of the stablecoin
issued through the Monetizer.

## Changed compared to Angle's Transmuter

Some changed has been made to the original Angle's Transmuter:

- Move from foundry gitmodule to Js dependencies
- Move from Yarn to Bun
- Move from AccessControl logics to Openzeppelin's AccessManaged
- Move from TransparentUpgradeableProxy to UUPSUpdgradeableProxy
- Restrict function to only one role due to AccessManager/AccessManaged logic (that means that Governor must also got
  Guardian role).
- Remove files that will not be used by Parallel (`SavingsVest.sol`, some `Configs/`, etc.)
- Renamed contracts (`AgToken` -> `TokenP`, `Transmuter` -> `Monetizer`)

## Documentation Links

### Angle documentation

- [Transmuter Whitepaper](https://docs.angle.money/overview/whitepapers)
- [Angle Documentation](https://docs.angle.money)
- [Angle Developers Documentation](https://developers.angle.money)

## Deployment Addresses

### Mainnet

### Testnet

| Contract              | Explore                                                                                                                                                |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| DiamondCut Facet      | [0xfb024919680e1b611f927615e3efb0294495a931](https://explorer-eden-testnet.binarybuilders.services/address/0xfb024919680e1b611f927615e3efb0294495a931) |
| DiamondLoupe Facet    | [0x5a41acc5c2c3d16e81d80e9dd76761b59a99dfba](https://explorer-eden-testnet.binarybuilders.services/address/0x5a41acc5c2c3d16e81d80e9dd76761b59a99dfba) |
| Getters Facet         | [0x7b2d8d775f0df4b01df8a44e0219f81973b59108](https://explorer-eden-testnet.binarybuilders.services/address/0x7b2d8d775f0df4b01df8a44e0219f81973b59108) |
| Redeemer Facet        | [0x1c9fda89dbe9843bbc4bc2ae1c074471ba227931](https://explorer-eden-testnet.binarybuilders.services/address/0x1c9fda89dbe9843bbc4bc2ae1c074471ba227931) |
| RewardHandler Facet   | [0x4f48cf7669f7b639346122a35da8288a28efe941](https://explorer-eden-testnet.binarybuilders.services/address/0x4f48cf7669f7b639346122a35da8288a28efe941) |
| SettersGovernor Facet | [0x0c2249a97af9d34810223d0c994a2d92d56a7156](https://explorer-eden-testnet.binarybuilders.services/address/0x0c2249a97af9d34810223d0c994a2d92d56a7156) |
| SettersGuardian Facet | [0xa2122c3290b15c9e9ccc4b6b1d7104415891127e](https://explorer-eden-testnet.binarybuilders.services/address/0xa2122c3290b15c9e9ccc4b6b1d7104415891127e) |
| Swapper Facet         | [0x8c5f0e4e4a9d6f72322ba9c5fbfc5deb05a15637](https://explorer-eden-testnet.binarybuilders.services/address/0x8c5f0e4e4a9d6f72322ba9c5fbfc5deb05a15637) |
| Monetizer USDmo       | [0xaa2825ebe6e0482c27ab02901ec39c7cdf279151](https://explorer-eden-testnet.binarybuilders.services/address/0xaa2825ebe6e0482c27ab02901ec39c7cdf279151) |
| sUSDmo (Savings)      | [0x3baa15bf01a69cc3ee81bb731f1335a7a7344854](https://explorer-eden-testnet.binarybuilders.services/address/0x3baa15bf01a69cc3ee81bb731f1335a7a7344854) |

## Security

### Trust assumptions of the Monetizer system

The governor role, which will be a multisig or an onchain governance, has all rights, including upgrading contracts,
removing funds, changing the code, etc.

The guardian role, which will be a multisig, has the right to: freeze assets, and potentially impact transient funds.
The idea is that any malicious behavior of the guardian should be fixable by the governor, and that the guardian
shouldn't be able to extract funds from the system.

### Known Issues

- Lack of support for ERC165
- At initialization, fees need to be < 100% for 100% exposure because the first exposures will be ~100%
- If at some point there are 0 funds in the system it’ll break as `amountToNextBreakPoint` will be 0
- In the burn, if there is one asset which is making 99% of the basket, and another one 1%: if the one making 1% depegs,
  it still impacts the burn for the asset that makes the majority of the funds
- The whitelist function for burns and redemptions are somehow breaking the fairness of the system as whitelisted actors
  will redeem more value
- The `getCollateralRatio` function may overflow and revert if the amount of stablecoins issued is really small (1
  billion x smaller) than the value of the collateral in the system.

### Audits

#### Angle audits

The Angle's Transmuter and savings smart contracts have been audited by Code4rena, find the audit report
[here](https://code4rena.com/reports/2023-06-angle).

#### Parallel audits

The Monetizer and savings contracts have been audited by:

#### Bailsec

Bailsec in April/March 2025, find the final audit report
[here](./docs/audits/Bailsec%20-%20Parallel%20Protocol%20-%20V3%20Core%20-%20Final%20Report.pdf)

#### Certora

Certora by formal verification in April/March 2025, find the final audit report
[here](./docs/audits/Certora_Report_Parallel_Monetizer_BridgeToken_final.pdf)

## Development

This repository is built on [Foundry](https://github.com/foundry-rs/foundry).

### Getting started

#### Install Foundry

If you don't have Foundry:
[Install foundry following the instructions.](https://book.getfoundry.sh/getting-started/installation)

#### Install packages

```bash
bun install
```

### Warning

This repository uses [`ffi`](https://book.getfoundry.sh/cheatcodes/ffi) in its test suite. Beware as a malicious actor
forking this repo could add malicious commands using this.

### Setup `.env` file

```bash
PRIVATE_KEY="PRIVATE KEY"
ALCHEMY_API_KEY="ALCHEMY_API_KEY"
```

For additional keys, you can check the [`.env.example`](/.env.example) file.

**Warning: always keep your confidential information safe**

### Compilation

Compilation of production contracts will be done using the via-ir pipeline.

However, tests do not compile with via-ir, and to run coverage the optimizer needs to be off. Therefore for development
and test purposes you can compile without optimizer.

```bash
bun run compile # with via-ir but without compiling tests files
bun run compile:dev # without optimizer
```

### Testing

Here are examples of how to run the test suite:

```bash
bun run test
```

You can also list tests:

```bash
FOUNDRY_PROFILE=dev forge test --list
FOUNDRY_PROFILE=dev forge test --list --json --match-test "testXXX*"
```

### Deploying

### Coverage

We recommend the use of this [vscode extension](ryanluker.vscode-coverage-gutters).

```bash
bun run coverage
```

You'll need to install lcov `brew install lcov` to visualize the coverage report.

### Gas report

```bash
bun run gas
```

### [Slither](https://github.com/crytic/slither)

```bash
bun run slither
```

## Contributing

If you're interested in contributing, please see our [contributions guidelines](./CONTRIBUTING.md).

## Questions & Feedback

For any question or feedback you can use [discord](https://discord.com/invite/mimodao). Don't hesitate to reach out on
[Twitter](https://twitter.com/mimo_labs) as well.

## Licensing

The primary license for this repository is the Business Source License 1.1 (`BUSL-1.1`). See [`LICENSE`](./LICENSE).
Minus the following exceptions:

- [Interfaces](contracts/interfaces/) have a General Public License
- [Some libraries](contracts/monetizer/libraries/LibHelpers.sol) have a General Public License

Each of these files states their license type.
