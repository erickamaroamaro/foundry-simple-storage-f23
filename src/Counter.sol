// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Um contrato simples de contador
/// @author Seu Nome
/// @notice Este contrato permite incrementar e definir um número
contract Counter {
    /// @dev Armazena o valor atual do contador
    uint256 public number;

    /// @notice Define um novo valor para o contador
    /// @param newNumber O novo valor a ser definido
    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    /// @notice Incrementa o contador em 1
    function increment() public {
        number++;
    }
}
