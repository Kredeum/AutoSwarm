// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

/*
Hitchens Order Statistics Tree v0.99

A Solidity Red-Black Tree library to store and maintain a sorted data
structure in a Red-Black binary search tree, with O(log 2n) insert, remove
and search time (and gas, approximately)

https://github.com/rob-Hitchens/OrderStatisticsTree

Copyright (c) Rob Hitchens. the MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Significant portions from BokkyPooBahsRedBlackTreeLibrary,
https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary

THIS SOFTWARE IS NOT TESTED OR AUDITED. DO NOT USE FOR PRODUCTION.
*/

library HitchensOrderStatisticsTreeLib {
    uint256 private constant EMPTY = 0;

    struct Node {
        uint256 parent;
        uint256 left;
        uint256 right;
        bool red;
        bytes32[] keys;
        mapping(bytes32 => uint256) keyMap;
        uint256 count;
    }

    struct Tree {
        uint256 root;
        mapping(uint256 => Node) nodes;
    }

    function first(Tree storage self) internal view returns (uint256 _value) {
        _value = self.root;
        if (_value == EMPTY) return 0;
        while (self.nodes[_value].left != EMPTY) {
            _value = self.nodes[_value].left;
        }
    }

    function exists(Tree storage self, uint256 value) internal view returns (bool _exists) {
        if (value == EMPTY) return false;
        if (value == self.root) return true;
        if (self.nodes[value].parent != EMPTY) return true;
        return false;
    }

    function keyExists(Tree storage self, bytes32 key, uint256 value) internal view returns (bool _exists) {
        if (!exists(self, value)) return false;
        return self.nodes[value].keys[self.nodes[value].keyMap[key]] == key;
    }

    function getNode(Tree storage self, uint256 value)
        internal
        view
        returns (uint256 _parent, uint256 _left, uint256 _right, bool _red, uint256 keyCount, uint256 __count)
    {
        require(exists(self, value), "OrderStatisticsTree(403) - Value does not exist.");
        Node storage gn = self.nodes[value];
        return (gn.parent, gn.left, gn.right, gn.red, gn.keys.length, gn.keys.length + gn.count);
    }

    function getNodeCount(Tree storage self, uint256 value) internal view returns (uint256 __count) {
        Node storage gn = self.nodes[value];
        return gn.keys.length + gn.count;
    }

    function valueKeyAtIndex(Tree storage self, uint256 value, uint256 index) internal view returns (bytes32 _key) {
        require(exists(self, value), "OrderStatisticsTree(404) - Value does not exist.");
        return self.nodes[value].keys[index];
    }

    function count(Tree storage self) internal view returns (uint256 _count) {
        return getNodeCount(self, self.root);
    }

    /* We don't use this functionality, so it is commented out to make audit easier

    function percentile(Tree storage self, uint value) internal view returns(uint _percentile) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _percentile = ((uint(1000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function permil(Tree storage self, uint value) internal view returns(uint _permil) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _permil = ((uint(10000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function atPercentile(Tree storage self, uint _percentile) internal view returns(uint _value) {
        uint findRank = (((_percentile * count(self))/uint(10)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }
    function atPermil(Tree storage self, uint _permil) internal view returns(uint _value) {
        uint findRank = (((_permil * count(self))/uint(100)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }
    function median(Tree storage self) internal view returns(uint value) {
        return atPercentile(self,50);
    }
    function below(Tree storage self, uint value) public view returns(uint _below) {
        if(count(self) > 0 && value > 0) _below = rank(self,value)-uint(1);
    }
    function above(Tree storage self, uint value) public view returns(uint _above) {
        if(count(self) > 0) _above = count(self)-rank(self,value);
    }
    function valueBelowEstimate(Tree storage self, uint estimate) public view returns(uint _below) {
        if(count(self) > 0 && estimate > 0) {
            uint  highestValue = last(self);
            uint  lowestValue = first(self);
            if(estimate < lowestValue) {
                return 0;
            }
            if(estimate >= highestValue) {
                return highestValue;
            }
            uint  rankOfValue = rank(self, estimate); // approximation
            _below = atRank(self, rankOfValue);
            if(_below > estimate) { // fix error in approximation
                rankOfValue--;
                _below = atRank(self, rankOfValue);
            }
        }
    }
    function valueAboveEstimate(Tree storage self, uint estimate) public view returns(uint _above) {
        if(count(self) > 0 && estimate > 0) {
            uint  highestValue = last(self);
            uint  lowestValue = first(self);
            if(estimate > highestValue) {
                return 0;
            }
            if(estimate <= lowestValue) {
                return lowestValue;
            }
            uint  rankOfValue = rank(self, estimate); // approximation
            _above = atRank(self, rankOfValue);
            if(_above < estimate) { // fix error in approximation
                rankOfValue++;
                _above = atRank(self, rankOfValue);
            }
        }
    }
    function rank(Tree storage self, uint value) internal view returns(uint _rank) {
        if(count(self) > 0) {
            bool finished;
            uint cursor = self.root;
            Node storage c = self.nodes[cursor];
            uint smaller = getNodeCount(self,c.left);
            while (!finished) {
                uint keyCount = c.keys.length;
                if(cursor == value) {
                    finished = true;
                } else {
                    if(cursor < value) {
                        cursor = c.right;
                        c = self.nodes[cursor];
                        smaller += keyCount + getNodeCount(self,c.left);
                    } else {
                        cursor = c.left;
                        c = self.nodes[cursor];
                        smaller -= (keyCount + getNodeCount(self,c.right));
                    }
                }
                if (!exists(self,cursor)) {
                    finished = true;
                }
            }
            return smaller + 1;
        }
    }
    function atRank(Tree storage self, uint _rank) internal view returns(uint _value) {
        bool finished;
        uint cursor = self.root;
        Node storage c = self.nodes[cursor];
        uint smaller = getNodeCount(self,c.left);
        while (!finished) {
            _value = cursor;
            c = self.nodes[cursor];
            uint keyCount = c.keys.length;
            if(smaller + 1 >= _rank && smaller + keyCount <= _rank) {
                _value = cursor;
                finished = true;
            } else {
                if(smaller + keyCount <= _rank) {
                    cursor = c.right;
                    c = self.nodes[cursor];
                    smaller += keyCount + getNodeCount(self,c.left);
                } else {
                    cursor = c.left;
                    c = self.nodes[cursor];
                    smaller -= (keyCount + getNodeCount(self,c.right));
                }
            }
            if (!exists(self,cursor)) {
                finished = true;
            }
        }
    }
    */

    function insert(Tree storage self, bytes32 key, uint256 value) internal {
        require(value != EMPTY, "OrderStatisticsTree(405) - Value to insert cannot be zero");
        require(
            !keyExists(self, key, value),
            "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again."
        );
        uint256 cursor;
        uint256 probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (value < probe) {
                probe = self.nodes[probe].left;
            } else if (value > probe) {
                probe = self.nodes[probe].right;
            } else if (value == probe) {
                self.nodes[probe].keys.push(key);
                self.nodes[probe].keyMap[key] = self.nodes[probe].keys.length - uint256(1);
                return;
            }
            self.nodes[cursor].count++;
        }
        Node storage nValue = self.nodes[value];
        nValue.parent = cursor;
        nValue.left = EMPTY;
        nValue.right = EMPTY;
        nValue.red = true;
        nValue.keys.push(key);
        nValue.keyMap[key] = nValue.keys.length - uint256(1);
        if (cursor == EMPTY) {
            self.root = value;
        } else if (value < cursor) {
            self.nodes[cursor].left = value;
        } else {
            self.nodes[cursor].right = value;
        }
        insertFixup(self, value);
    }

    function remove(Tree storage self, bytes32 key, uint256 value) internal {
        require(value != EMPTY, "OrderStatisticsTree(407) - Value to delete cannot be zero");
        require(keyExists(self, key, value), "OrderStatisticsTree(408) - Value to delete does not exist.");
        Node storage nValue = self.nodes[value];
        uint256 rowToDelete = nValue.keyMap[key];
        bytes32 last = nValue.keys[nValue.keys.length - uint256(1)];
        nValue.keys[rowToDelete] = last;
        nValue.keyMap[last] = rowToDelete;
        nValue.keys.pop();
        uint256 probe;
        uint256 cursor;
        if (nValue.keys.length == 0) {
            if (self.nodes[value].left == EMPTY || self.nodes[value].right == EMPTY) {
                cursor = value;
            } else {
                cursor = self.nodes[value].right;
                while (self.nodes[cursor].left != EMPTY) {
                    cursor = self.nodes[cursor].left;
                }
            }
            if (self.nodes[cursor].left != EMPTY) {
                probe = self.nodes[cursor].left;
            } else {
                probe = self.nodes[cursor].right;
            }
            uint256 cursorParent = self.nodes[cursor].parent;
            self.nodes[probe].parent = cursorParent;
            if (cursorParent != EMPTY) {
                if (cursor == self.nodes[cursorParent].left) {
                    self.nodes[cursorParent].left = probe;
                } else {
                    self.nodes[cursorParent].right = probe;
                }
            } else {
                self.root = probe;
            }
            bool doFixup = !self.nodes[cursor].red;
            if (cursor != value) {
                replaceParent(self, cursor, value);
                self.nodes[cursor].left = self.nodes[value].left;
                self.nodes[self.nodes[cursor].left].parent = cursor;
                self.nodes[cursor].right = self.nodes[value].right;
                self.nodes[self.nodes[cursor].right].parent = cursor;
                self.nodes[cursor].red = self.nodes[value].red;
                (cursor, value) = (value, cursor);
                fixCountRecurse(self, value);
            }
            if (doFixup) {
                removeFixup(self, probe);
            }
            fixCountRecurse(self, cursorParent);
            delete self.nodes[cursor];
        }
    }

    function fixCountRecurse(Tree storage self, uint256 value) private {
        while (value != EMPTY) {
            self.nodes[value].count =
                getNodeCount(self, self.nodes[value].left) + getNodeCount(self, self.nodes[value].right);
            value = self.nodes[value].parent;
        }
    }

    function treeMinimum(Tree storage self, uint256 value) private view returns (uint256) {
        while (self.nodes[value].left != EMPTY) {
            value = self.nodes[value].left;
        }
        return value;
    }

    function treeMaximum(Tree storage self, uint256 value) private view returns (uint256) {
        while (self.nodes[value].right != EMPTY) {
            value = self.nodes[value].right;
        }
        return value;
    }

    function rotateLeft(Tree storage self, uint256 value) private {
        uint256 cursor = self.nodes[value].right;
        uint256 parent = self.nodes[value].parent;
        uint256 cursorLeft = self.nodes[cursor].left;
        self.nodes[value].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].left) {
            self.nodes[parent].left = cursor;
        } else {
            self.nodes[parent].right = cursor;
        }
        self.nodes[cursor].left = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count =
            getNodeCount(self, self.nodes[value].left) + getNodeCount(self, self.nodes[value].right);
        self.nodes[cursor].count =
            getNodeCount(self, self.nodes[cursor].left) + getNodeCount(self, self.nodes[cursor].right);
    }

    function rotateRight(Tree storage self, uint256 value) private {
        uint256 cursor = self.nodes[value].left;
        uint256 parent = self.nodes[value].parent;
        uint256 cursorRight = self.nodes[cursor].right;
        self.nodes[value].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].right) {
            self.nodes[parent].right = cursor;
        } else {
            self.nodes[parent].left = cursor;
        }
        self.nodes[cursor].right = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count =
            getNodeCount(self, self.nodes[value].left) + getNodeCount(self, self.nodes[value].right);
        self.nodes[cursor].count =
            getNodeCount(self, self.nodes[cursor].left) + getNodeCount(self, self.nodes[cursor].right);
    }

    function insertFixup(Tree storage self, uint256 value) private {
        uint256 cursor;
        while (value != self.root && self.nodes[self.nodes[value].parent].red) {
            uint256 valueParent = self.nodes[value].parent;
            if (valueParent == self.nodes[self.nodes[valueParent].parent].left) {
                cursor = self.nodes[self.nodes[valueParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].right) {
                        value = valueParent;
                        rotateLeft(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateRight(self, self.nodes[valueParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[valueParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].left) {
                        value = valueParent;
                        rotateRight(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateLeft(self, self.nodes[valueParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }

    function replaceParent(Tree storage self, uint256 a, uint256 b) private {
        uint256 bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }

    function removeFixup(Tree storage self, uint256 value) private {
        uint256 cursor;
        while (value != self.root && !self.nodes[value].red) {
            uint256 valueParent = self.nodes[value].parent;
            if (value == self.nodes[valueParent].left) {
                cursor = self.nodes[valueParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateLeft(self, valueParent);
                    cursor = self.nodes[valueParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[valueParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, valueParent);
                    value = self.root;
                }
            } else {
                cursor = self.nodes[valueParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateRight(self, valueParent);
                    cursor = self.nodes[valueParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[valueParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, valueParent);
                    value = self.root;
                }
            }
        }
        self.nodes[value].red = false;
    }
}

/**
 * @title PostageStamp contract
 * @author The Swarm Authors
 * @dev The postage stamp contracts allows users to create and manage postage stamp batches.
 * The current balance for each batch is stored ordered in descending order of normalised balance.
 * Balance is normalised to be per chunk and the total spend since the contract was deployed, i.e. when a batch
 * is bought, its per-chunk balance is supplemented with the current cost of storing one chunk since the beginning of time,
 * as if the batch had existed since the contract's inception. During the _expiry_ process, each of these balances is
 * checked against the _currentTotalOutPayment_, a similarly normalised figure that represents the current cost of
 * storing one chunk since the beginning of time. A batch with a normalised balance less than _currentTotalOutPayment_
 * is treated as expired.
 *
 * The _currentTotalOutPayment_ is calculated using _totalOutPayment_ which is updated during _setPrice_ events so
 * that the applicable per-chunk prices can be charged for the relevant periods of time. This can then be multiplied
 * by the amount of chunks which are allowed to be stamped by each batch to get the actual cost of storage.
 *
 * The amount of chunks a batch can stamp is determined by the _bucketDepth_. A batch may store a maximum of 2^depth chunks.
 * The global figure for the currently allowed chunks is tracked by _validChunkCount_ and updated during batch _expiry_ events.
 */

contract PostageStamp is AccessControl, Pausable {
    using HitchensOrderStatisticsTreeLib for HitchensOrderStatisticsTreeLib.Tree;

    /**
     * @dev Emitted when a new batch is created.
     */
    event BatchCreated(
        bytes32 indexed batchId,
        uint256 totalAmount,
        uint256 normalisedBalance,
        address owner,
        uint8 depth,
        uint8 bucketDepth,
        bool immutableFlag
    );

    event PotWithdrawn(address recipient, uint256 totalAmount);

    /**
     * @dev Emitted when an existing batch is topped up.
     */
    event BatchTopUp(bytes32 indexed batchId, uint256 topupAmount, uint256 normalisedBalance);

    /**
     * @dev Emitted when the depth of an existing batch increases.
     */
    event BatchDepthIncrease(bytes32 indexed batchId, uint8 newDepth, uint256 normalisedBalance);

    /**
     * @dev Emitted on every price update.
     */
    event PriceUpdate(uint256 price);

    struct Batch {
        // Owner of this batch (0 if not valid).
        address owner;
        // Current depth of this batch.
        uint8 depth;
        //
        uint8 bucketDepth;
        // Whether this batch is immutable.
        bool immutableFlag;
        // Normalised balance per chunk.
        uint256 normalisedBalance;
        //
        uint256 lastUpdatedBlockNumber;
    }

    // Role allowed to increase totalOutPayment.
    bytes32 public constant PRICE_ORACLE_ROLE = keccak256("PRICE_ORACLE");
    // Role allowed to pause
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // Role allowed to withdraw the pot.
    bytes32 public constant REDISTRIBUTOR_ROLE = keccak256("REDISTRIBUTOR_ROLE");

    // Associate every batch id with batch data.
    mapping(bytes32 => Batch) public batches;
    // Store every batch id ordered by normalisedBalance.
    HitchensOrderStatisticsTreeLib.Tree tree;

    // Address of the ERC20 token this contract references.
    address public bzzToken;

    // Total out payment per chunk, at the blockheight of the last price change.
    uint256 private totalOutPayment;

    // Minimum allowed depth of bucket.
    uint8 public minimumBucketDepth;

    // Combined global chunk capacity of valid batches remaining at the blockheight expire() was last called.
    uint256 public validChunkCount;

    // Lottery pot at last update.
    uint256 public pot;

    // blocks in 24 hours ~ 24 * 60 * 60 / 5 = 17280
    uint256 public minimumValidityBlocks = 17280;

    // Price from the last update.
    uint256 public lastPrice = 0;
    // Block at which the last update occured.
    uint256 public lastUpdatedBlock;
    // Normalised balance at the blockheight expire() was last called.
    uint256 public lastExpiryBalance;

    /**
     * @param _bzzToken The ERC20 token address to reference in this contract.
     * @param _minimumBucketDepth The minimum bucket depth of batches that can be purchased.
     */
    constructor(address _bzzToken, uint8 _minimumBucketDepth, address multisig) {
        bzzToken = _bzzToken;
        minimumBucketDepth = _minimumBucketDepth;
        _setupRole(DEFAULT_ADMIN_ROLE, multisig);
        _setupRole(PAUSER_ROLE, msg.sender);
    }

    /**
     * @notice Create a new batch.
     * @dev At least `_initialBalancePerChunk*2^depth` tokens must be approved in the ERC20 token contract.
     * @param _owner Owner of the new batch.
     * @param _initialBalancePerChunk Initial balance per chunk.
     * @param _depth Initial depth of the new batch.
     * @param _nonce A random value used in the batch id derivation to allow multiple batches per owner.
     * @param _immutable Whether the batch is mutable.
     */
    function createBatch(
        address _owner,
        uint256 _initialBalancePerChunk,
        uint8 _depth,
        uint8 _bucketDepth,
        bytes32 _nonce,
        bool _immutable
    ) external whenNotPaused {
        require(_owner != address(0), "owner cannot be the zero address");
        // bucket depth should be non-zero and smaller than the depth
        require(
            _bucketDepth != 0 && minimumBucketDepth <= _bucketDepth && _bucketDepth < _depth, "invalid bucket depth"
        );
        // derive batchId from msg.sender to ensure another party cannot use the same batch id and frontrun us.
        bytes32 batchId = keccak256(abi.encode(msg.sender, _nonce));
        require(batches[batchId].owner == address(0), "batch already exists");
        require(
            _initialBalancePerChunk >= minimumInitialBalancePerChunk(),
            "insufficient initial balance for 24h minimum validity"
        );
        // per chunk balance multiplied by the batch size in chunks must be transferred from the sender
        uint256 totalAmount = _initialBalancePerChunk * (1 << _depth);
        require(ERC20(bzzToken).transferFrom(msg.sender, address(this), totalAmount), "failed transfer");

        // normalisedBalance is an absolute value per chunk, as if the batch had existed
        // since the block the contract was deployed, so we must supplement this batch's
        // _initialBalancePerChunk with the currentTotalOutPayment()
        uint256 normalisedBalance = currentTotalOutPayment() + (_initialBalancePerChunk);

        //update validChunkCount to remove currently expired batches
        expireLimited(type(uint256).max);

        //then add the chunks this batch will contribute
        validChunkCount += 1 << _depth;

        batches[batchId] = Batch({
            owner: _owner,
            depth: _depth,
            bucketDepth: _bucketDepth,
            immutableFlag: _immutable,
            normalisedBalance: normalisedBalance,
            lastUpdatedBlockNumber: block.number
        });

        require(normalisedBalance > 0, "normalisedBalance cannot be zero");

        // insert into the ordered tree
        tree.insert(batchId, normalisedBalance);

        emit BatchCreated(batchId, totalAmount, normalisedBalance, _owner, _depth, _bucketDepth, _immutable);
    }

    /**
     * @notice Manually create a new batch when faciliatating migration, can only be called by the Admin role.
     * @dev At least `_initialBalancePerChunk*2^depth` tokens must be approved in the ERC20 token contract.
     * @param _owner Owner of the new batch.
     * @param _initialBalancePerChunk Initial balance per chunk of the batch.
     * @param _depth Initial depth of the new batch.
     * @param _batchId BatchId being copied (from previous version contract data).
     * @param _immutable Whether the batch is mutable.
     */
    function copyBatch(
        address _owner,
        uint256 _initialBalancePerChunk,
        uint8 _depth,
        uint8 _bucketDepth,
        bytes32 _batchId,
        bool _immutable
    ) external whenNotPaused {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "only administrator can use copy method");
        require(_owner != address(0), "owner cannot be the zero address");
        require(_bucketDepth != 0 && _bucketDepth < _depth, "invalid bucket depth");
        require(batches[_batchId].owner == address(0), "batch already exists");

        // per chunk balance multiplied by the batch size in chunks must be transferred from the sender
        uint256 totalAmount = _initialBalancePerChunk * (1 << _depth);
        require(ERC20(bzzToken).transferFrom(msg.sender, address(this), totalAmount), "failed transfer");

        uint256 normalisedBalance = currentTotalOutPayment() + (_initialBalancePerChunk);

        validChunkCount += 1 << _depth;

        batches[_batchId] = Batch({
            owner: _owner,
            depth: _depth,
            bucketDepth: _bucketDepth,
            immutableFlag: _immutable,
            normalisedBalance: normalisedBalance,
            lastUpdatedBlockNumber: block.number
        });

        require(normalisedBalance > 0, "normalisedBalance cannot be zero");

        tree.insert(_batchId, normalisedBalance);

        emit BatchCreated(_batchId, totalAmount, normalisedBalance, _owner, _depth, _bucketDepth, _immutable);
    }

    /**
     * @notice Top up an existing batch.
     * @dev At least `_topupAmountPerChunk*2^depth` tokens must be approved in the ERC20 token contract.
     * @param _batchId The id of an existing batch.
     * @param _topupAmountPerChunk The amount of additional tokens to add per chunk.
     */
    function topUp(bytes32 _batchId, uint256 _topupAmountPerChunk) external whenNotPaused {
        Batch storage batch = batches[_batchId];
        require(batch.owner != address(0), "batch does not exist or has expired");
        require(batch.normalisedBalance > currentTotalOutPayment(), "batch already expired");
        require(batch.depth > minimumBucketDepth, "batch too small to renew");
        require(
            remainingBalance(_batchId) + (_topupAmountPerChunk) >= minimumInitialBalancePerChunk(),
            "insufficient topped up balance for 24h minimum validity"
        );

        // per chunk balance multiplied by the batch size in chunks must be transferred from the sender
        uint256 totalAmount = _topupAmountPerChunk * (1 << batch.depth);
        require(ERC20(bzzToken).transferFrom(msg.sender, address(this), totalAmount), "failed transfer");
        // update by removing batch and then reinserting
        tree.remove(_batchId, batch.normalisedBalance);
        batch.normalisedBalance = batch.normalisedBalance + (_topupAmountPerChunk);
        tree.insert(_batchId, batch.normalisedBalance);

        emit BatchTopUp(_batchId, totalAmount, batch.normalisedBalance);
    }

    /**
     * @notice Increase the depth of an existing batch.
     * @dev Can only be called by the owner of the batch.
     * @param _batchId the id of an existing batch.
     * @param _newDepth the new (larger than the previous one) depth for this batch.
     */
    function increaseDepth(bytes32 _batchId, uint8 _newDepth) external whenNotPaused {
        Batch storage batch = batches[_batchId];

        require(batch.owner == msg.sender, "not batch owner");
        require(minimumBucketDepth < _newDepth && batch.depth < _newDepth, "depth not increasing");
        require(!batch.immutableFlag, "batch is immutable");
        require(batch.normalisedBalance > currentTotalOutPayment(), "batch already expired");

        uint8 depthChange = _newDepth - batch.depth;
        // divide by the change in batch size (2^depthChange)
        uint256 newRemainingBalance = remainingBalance(_batchId) / (1 << depthChange);

        require(
            newRemainingBalance >= minimumInitialBalancePerChunk(),
            "remaining balance after depth increase wouldn't meet 24h minimum validity"
        );
        // expire batches up to current block before amending validChunkCount to include
        // the new chunks resultant of the depth increase
        expireLimited(type(uint256).max);
        validChunkCount += (1 << _newDepth) - (1 << batch.depth);

        // update by removing batch and then reinserting
        tree.remove(_batchId, batch.normalisedBalance);
        batch.depth = _newDepth;
        batch.lastUpdatedBlockNumber = block.number;

        batch.normalisedBalance = currentTotalOutPayment() + (newRemainingBalance);
        tree.insert(_batchId, batch.normalisedBalance);

        emit BatchDepthIncrease(_batchId, _newDepth, batch.normalisedBalance);
    }

    /**
     * @notice Return the per chunk balance not yet used up.
     * @param _batchId The id of an existing batch.
     */
    function remainingBalance(bytes32 _batchId) public view returns (uint256) {
        Batch storage batch = batches[_batchId];
        require(batch.owner != address(0), "batch does not exist or expired");
        if (batch.normalisedBalance <= currentTotalOutPayment()) {
            return 0;
        }
        return batch.normalisedBalance - currentTotalOutPayment();
    }

    /**
     * @notice Set a new price.
     * @dev Can only be called by the price oracle role.
     * @param _price The new price.
     */
    function setPrice(uint256 _price) external {
        require(hasRole(PRICE_ORACLE_ROLE, msg.sender), "only price oracle can set the price");

        // if there was a last price, add the outpayment since the last update
        // using the last price to _totalOutPayment_. if there was not a lastPrice,
        // the lastprice must have been zero.
        if (lastPrice != 0) {
            totalOutPayment = currentTotalOutPayment();
        }

        lastPrice = _price;
        lastUpdatedBlock = block.number;

        emit PriceUpdate(_price);
    }

    function setMinimumValidityBlocks(uint256 _value) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "only administrator can set minimum validity blocks");
        minimumValidityBlocks = _value;
    }

    /**
     * @notice Total per-chunk cost since the contract's deployment.
     * @dev Returns the total normalised all-time per chunk payout.
     * Only Batches with a normalised balance greater than this are valid.
     */
    function currentTotalOutPayment() public view returns (uint256) {
        uint256 blocks = block.number - lastUpdatedBlock;
        uint256 increaseSinceLastUpdate = lastPrice * (blocks);
        return totalOutPayment + (increaseSinceLastUpdate);
    }

    function minimumInitialBalancePerChunk() public view returns (uint256) {
        return minimumValidityBlocks * lastPrice;
    }

    /**
     * @notice Pause the contract.
     * @dev Can only be called by the pauser when not paused.
     * The contract can be provably stopped by renouncing the pauser role and the admin role once paused.
     */
    function pause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "only pauser can pause");
        _pause();
    }

    /**
     * @notice Unpause the contract.
     * @dev Can only be called by the pauser role while paused.
     */
    function unPause() public {
        require(hasRole(PAUSER_ROLE, msg.sender), "only pauser can unpause");
        _unpause();
    }

    /**
     * @notice Return true if no batches exist
     */
    function isBatchesTreeEmpty() public view returns (bool) {
        return tree.count() == 0;
    }

    /**
     * @notice Get the first batch id ordered by ascending normalised balance.
     * @dev If more than one batch id, return index at 0, if no batches, revert.
     */
    function firstBatchId() public view returns (bytes32) {
        uint256 val = tree.first();
        require(val > 0, "no batches exist");
        return tree.valueKeyAtIndex(val, 0);
    }

    /**
     * @notice Reclaims a limited number of expired batches
     * @dev Can be used if reclaiming all expired batches would exceed the block gas limit, causing other
     * contract method calls to fail.
     * @param limit The maximum number of batches to expire.
     */
    function expireLimited(uint256 limit) public {
        // the lower bound of the normalised balance for which we will check if batches have expired
        uint256 leb = lastExpiryBalance;
        uint256 i;
        for (i = 0; i < limit; i++) {
            if (isBatchesTreeEmpty()) {
                lastExpiryBalance = currentTotalOutPayment();
                break;
            }
            // get the batch with the smallest normalised balance
            bytes32 fbi = firstBatchId();
            // if the batch with the smallest balance has not yet expired
            // we have already reached the end of the batches we need
            // to expire, so exit the loop
            if (remainingBalance(fbi) > 0) {
                // the upper bound of the normalised balance for which we will check if batches have expired
                // value is updated when there are no expired batches left
                lastExpiryBalance = currentTotalOutPayment();
                break;
            }
            // otherwise, the batch with the smallest balance has expired,
            // so we must remove the chunks this batch contributes to the global validChunkCount
            Batch storage batch = batches[fbi];
            uint256 batchSize = 1 << batch.depth;
            require(validChunkCount >= batchSize, "insufficient valid chunk count");
            validChunkCount -= batchSize;
            // since the batch expired _during_ the period we must add
            // remaining normalised payout for this batch only
            pot += batchSize * (batch.normalisedBalance - leb);
            tree.remove(fbi, batch.normalisedBalance);
            delete batches[fbi];
        }
        // then, for all batches that have _not_ expired during the period
        // add the total normalised payout of all batches
        // multiplied by the remaining total valid chunk count
        // to the pot for the period since the last expiry

        require(lastExpiryBalance >= leb, "current total outpayment should never decrease");

        // then, for all batches that have _not_ expired during the period
        // add the total normalised payout of all batches
        // multiplied by the remaining total valid chunk count
        // to the pot for the period since the last expiry
        pot += validChunkCount * (lastExpiryBalance - leb);
    }

    /**
     * @notice Indicates whether expired batches exist.
     */
    function expiredBatchesExist() public view returns (bool) {
        if (isBatchesTreeEmpty()) {
            return false;
        }
        return (remainingBalance(firstBatchId()) <= 0);
    }

    /**
     * @notice The current pot.
     */
    function totalPot() public returns (uint256) {
        expireLimited(type(uint256).max);
        uint256 balance = ERC20(bzzToken).balanceOf(address(this));
        return pot < balance ? pot : balance;
    }

    /**
     * @notice Withdraw the pot, authorised callers only.
     * @param beneficiary Recieves the current total pot.
     */

    function withdraw(address beneficiary) external {
        require(hasRole(REDISTRIBUTOR_ROLE, msg.sender), "only redistributor can withdraw from the contract");
        uint256 totalAmount = totalPot();
        require(ERC20(bzzToken).transfer(beneficiary, totalAmount), "failed transfer");

        emit PotWithdrawn(beneficiary, totalAmount);
        pot = 0;
    }

    function batchOwner(bytes32 _batchId) public view returns (address) {
        return batches[_batchId].owner;
    }

    function batchDepth(bytes32 _batchId) public view returns (uint8) {
        return batches[_batchId].depth;
    }

    function batchBucketDepth(bytes32 _batchId) public view returns (uint8) {
        return batches[_batchId].bucketDepth;
    }

    function batchImmutableFlag(bytes32 _batchId) public view returns (bool) {
        return batches[_batchId].immutableFlag;
    }

    function batchNormalisedBalance(bytes32 _batchId) public view returns (uint256) {
        return batches[_batchId].normalisedBalance;
    }

    function batchLastUpdatedBlockNumber(bytes32 _batchId) public view returns (uint256) {
        return batches[_batchId].lastUpdatedBlockNumber;
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// OpenZeppelin Contracts v4.4.1 (interfaces/IERC1271.sol)

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * _Available since v4.1._
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/SignatureChecker.sol)

// OpenZeppelin Contracts (last updated v4.8.0) (utils/cryptography/ECDSA.sol)

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV // Deprecated in v4.8
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage)
        internal
        returns (bytes memory)
    {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage)
        internal
        returns (bytes memory)
    {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage)
        internal
        view
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage)
        internal
        pure
        returns (bytes memory)
    {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

/**
 * @dev Signature verification helper that can be used instead of `ECDSA.recover` to seamlessly support both ECDSA
 * signatures from externally owned accounts (EOAs) as well as ERC1271 signatures from smart contract wallets like
 * Argent and Gnosis Safe.
 *
 * _Available since v4.1._
 */
library SignatureChecker {
    /**
     * @dev Checks if a signature is valid for a given signer and data hash. If the signer is a smart contract, the
     * signature is validated against that smart contract using ERC1271, otherwise it's validated using `ECDSA.recover`.
     *
     * NOTE: Unlike ECDSA signatures, contract signatures are revocable, and the outcome of this function can thus
     * change through time. It could return true at block N and false at block N+1 (or the opposite).
     */
    function isValidSignatureNow(address signer, bytes32 hash, bytes memory signature) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) =
            signer.staticcall(abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature));
        return (
            success && result.length == 32
                && abi.decode(result, (bytes32)) == bytes32(IERC1271.isValidSignature.selector)
        );
    }
}

/// @dev the ERC-165 identifier for this interface is `0x6faff5f1`
interface IERC6551Account {
    /**
     * @dev Allows the account to receive Ether
     *
     * Accounts MUST implement a `receive` function
     *
     * Accounts MAY perform arbitrary logic to restrict conditions
     * under which Ether can be received
     */
    receive() external payable;

    /**
     * @dev Returns the identifier of the non-fungible token which owns the account
     *
     * The return value of this function MUST be constant - it MUST NOT change over time
     *
     * @return chainId       The EIP-155 ID of the chain the token exists on
     * @return tokenContract The contract address of the token
     * @return tokenId       The ID of the token
     */
    function token() external view returns (uint256 chainId, address tokenContract, uint256 tokenId);

    /**
     * @dev Returns a value that SHOULD be modified each time the account changes state
     *
     * @return The current account state
     */
    function state() external view returns (uint256);

    /**
     * @dev Returns a magic value indicating whether a given signer is authorized to act on behalf
     * of the account
     *
     * MUST return the bytes4 magic value 0x523e3260 if the given signer is valid
     *
     * By default, the holder of the non-fungible token the account is bound to MUST be considered
     * a valid signer
     *
     * Accounts MAY implement additional authorization logic which invalidates the holder as a
     * signer or grants signing permissions to other non-holder accounts
     *
     * @param  signer     The address to check signing authorization for
     * @param  context    Additional data used to determine whether the signer is valid
     * @return magicValue Magic value indicating whether the signer is valid
     */
    function isValidSigner(address signer, bytes calldata context) external view returns (bytes4 magicValue);
}

/// @dev the ERC-165 identifier for this interface is `0x74420f4c`
interface IERC6551Executable {
    /**
     * @dev Executes a low-level operation if the caller is a valid signer on the account
     *
     * Reverts and bubbles up error if operation fails
     *
     * @param to        The target address of the operation
     * @param value     The Ether value to be sent to the target
     * @param data      The encoded operation calldata
     * @param operation A value indicating the type of operation to perform
     *
     * Accounts implementing this interface MUST accept the following operation parameter values:
     * - 0 = CALL
     * - 1 = DELEGATECALL
     * - 2 = CREATE
     * - 3 = CREATE2
     *
     * Accounts implementing this interface MAY support additional operations or restrict a signer's
     * ability to execute certain operations
     *
     * @return The result of the operation
     */
    function execute(address to, uint256 value, bytes calldata data, uint256 operation)
        external
        payable
        returns (bytes memory);
}

contract SimpleERC6551Account is IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    uint256 public state;

    receive() external payable {}

    function execute(address to, uint256 value, bytes calldata data, uint256 operation)
        external
        payable
        returns (bytes memory result)
    {
        require(_isValidSigner(msg.sender), "Invalid signer");
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSigner(address signer, bytes calldata) external view returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (
            interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC6551Account).interfaceId
                || interfaceId == type(IERC6551Executable).interfaceId
        );
    }

    function token() public view returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }
}

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Create2.sol)

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) internal returns (address addr) {
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer)
        internal
        pure
        returns (address addr)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
    }
}

interface IERC6551Registry {
    /**
     * @dev The registry SHALL emit the AccountCreated event upon successful account creation
     */
    event AccountCreated(
        address account,
        address indexed implementation,
        uint256 chainId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 salt
    );

    /**
     * @dev Creates a token bound account for a non-fungible token
     *
     * If account has already been created, returns the account address without calling create2
     *
     * If initData is not empty and account has not yet been created, calls account with
     * provided initData after creation
     *
     * Emits AccountCreated event
     *
     * @return the address of the account
     */
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 seed,
        bytes calldata initData
    ) external returns (address);

    /**
     * @dev Returns the computed token bound account address for a non-fungible token
     *
     * @return The computed address of the token bound account
     */
    function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt)
        external
        view
        returns (address);
}

library ERC6551BytecodeLib {
    function getCreationCode(
        address implementation_,
        uint256 chainId_,
        address tokenContract_,
        uint256 tokenId_,
        uint256 salt_
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            hex"3d60ad80600a3d3981f3363d3d373d3d3d363d73",
            implementation_,
            hex"5af43d82803e903d91602b57fd5bf3",
            abi.encode(salt_, chainId_, tokenContract_, tokenId_)
        );
    }
}

contract ERC6551Registry is IERC6551Registry {
    error AccountCreationFailed();

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external returns (address) {
        bytes memory code = ERC6551BytecodeLib.getCreationCode(implementation, chainId, tokenContract, tokenId, salt);

        address _account = Create2.computeAddress(bytes32(salt), keccak256(code));

        if (_account.code.length != 0) return _account;

        emit AccountCreated(_account, implementation, chainId, tokenContract, tokenId, salt);

        assembly {
            _account := create2(0, add(code, 0x20), mload(code), salt)
        }

        if (_account == address(0)) revert AccountCreationFailed();

        if (initData.length != 0) {
            (bool success, bytes memory result) = _account.call(initData);

            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }

        return _account;
    }

    function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt)
        external
        view
        returns (address)
    {
        bytes32 bytecodeHash =
            keccak256(ERC6551BytecodeLib.getCreationCode(implementation, chainId, tokenContract, tokenId, salt));

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }
}

interface IPostageStampLegacy {
    function batches(bytes32) external returns (address, uint8, bool, uint256);
}

contract AutoSwarmAccount is SimpleERC6551Account {
    PostageStamp internal _postageStamp;
    IERC20 internal _bzzToken;
    uint8 internal _minDepth;
    uint256 internal _n;

    function initialize(address payable postageStamp_) external {
        _postageStamp = PostageStamp(postageStamp_);
        _minDepth = _postageStamp.minimumBucketDepth();
        _bzzToken = IERC20(_postageStamp.bzzToken());
    }

    function stampsBuy(uint256 ttl, uint8 depth) public returns (bytes32) {
        bytes32 nonce = keccak256(abi.encode(address(this), _n++));

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.createBatch(address(this), ttl, depth, _minDepth, nonce, false);

        return keccak256(abi.encode(address(this), nonce));
    }

    function stampsTopUp(bytes32 batchId, uint256 ttl) public {
        uint8 depth;
        if (block.chainid == 100) {
            (, depth,,) = IPostageStampLegacy(address(_postageStamp)).batches(batchId);
        } else {
            (, depth,,,,) = _postageStamp.batches(batchId);
        }

        _bzzToken.approve(address(_postageStamp), ttl << depth);
        _postageStamp.topUp(batchId, ttl);
    }

    function stampsIncreaseDepth(bytes32 batchId, uint8 newDepth) external {
        _postageStamp.increaseDepth(batchId, newDepth);
    }

    function withdraw(address token) external {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        (bool success,) = owner().call{value: address(this).balance}("");
        require(success, "Withdraw failed!");
    }
}
