pragma ^0.6;

// Import interface for ERC20 standard
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

// ... rest of your contract ...
contract aaveFolding{

    function openPosition(uint _amount, address _tokenAddress) external {
        IERC20(_tokenAddress).approve(address(self), _amount*5);
        // Retrieve LendingPool address
        LendingPoolAddressesProvider provider = LendingPoolAddressesProvider(address( 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8)); // mainnet address, for other addresses: https://docs.aave.com/developers/developing-on-aave/deployed-contract-instances
        LendingPool lendingPool = LendingPool(provider.getLendingPool());
        //approving lending pool to spend token
        IERC20(_tokenAddress).approve(provider.getLendingPoolCore(), _amount*5);
        // Deposit DAI
        uint16 referral = 0;
        uint256 amount = _amount * 1e18;
        lendingPool.deposit(_tokenAddress, amount, referral);
        setAsCollateral(_tokenAddress, lendingPool);
        foldPosition(amount ,_tokenAddress, lendingPool);
    }
    function setAsCollateral(address _tokenAddress, LendingPool _lendingPool) internal{
        bool useAsCollateral = true;
        lendingPool.setUserUseReserveAsCollateral(_tokenAddress, useAsCollateral);
    }
    
    function foldPosition(uint _amount, address _tokenAddress, LendingPool _lendingPool) internal {
        uint maxBorrow = _amount;
        /// 1 is stable rate, 2 is variable rate
        uint256 variableRate = 2;
        uint256 referral = 0;
        (, uint liquidationThreshold,,, bool usageAsCollateralEnabled, bool borrowingEnabled, ,, bool isActive) = getReserveConfigurationData(_tokenAddress);
        require(usageAsCollateralEnabled == true && borrowingEnabled == true && isActive == true);
        for(uint i = 0; i<4; i++){
            /// Borrow method call
            lendingPool.borrow(_tokenAddress, _amount*liquidationThreshold^i, variableRate, referral);
        }
        
    }
}
