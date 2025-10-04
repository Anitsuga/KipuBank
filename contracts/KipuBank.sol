// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title KipuBank
 * @notice Bóveda simple para depositar y retirar ETH por usuario con límites.
 * @author Agustina
 * @custom:security No usar en producción sin auditoría. Este contrato es para fines educativos.
 */
contract KipuBank {

    /*//////////////////////////////////////////////////////////////
                             STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Dirección que despliega el contrato (propietario administrativo opcional)
    address public immutable i_propietario;

    /// @notice Límite máximo global de ETH que puede contener el banco (en wei)
    uint256 public immutable i_bankCap;

    /// @notice Límite máximo por retiro por transacción (en wei)
    uint256 public immutable i_limiteExtraccionPorTx;

    /// @notice Mapeo: dirección => saldo acumulado en la bóveda del usuario (wei)
    mapping(address => uint256) public s_balances;

    /// @notice Mapeo: dirección => número de depósitos realizados por ese usuario
    mapping(address => uint256) public s_numeroDepositosPorUsuario;

    /// @notice Mapeo: dirección => número de retiros realizados por ese usuario
    mapping(address => uint256) public s_numeroRetirosPorUsuario;

    /// @notice Total de depósitos realizados en el banco (conteo)
    uint256 public s_depositosTotales;

    /// @notice Total de retiros realizados en el banco (conteo)
    uint256 public s_extraccionesTotales;

    /// @notice Total de ETH depositados acumulados en el banco (wei)
    uint256 public s_totalDepositado;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Evento emitido cuando un usuario deposita ETH
    event KipuBank_Deposito(address indexed depositante, uint256 value, uint256 balanceNuevo);

    /// @notice Evento emitido cuando un usuario retira ETH
    event KipuBank_Extraccion(address indexed retirador, uint256 value, uint256 balanceNuevo);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error KipuBank_mayorAlBalance(uint256 intento, uint256 disponible);
    error KipuBank_MontoCero();
    error KipuBank_BalanceInsuficiente(uint256 solicitado, uint256 disponible);
    error KipuBank_LimiteExtraccionExcedido(uint256 solicitado, uint256 limite);
    error KipuBank_TransferenciaFallida(bytes razon);

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier noCero(uint256 _value) {
        if (_value == 0) revert KipuBank_MontoCero();
        _;
    }

    modifier menorAlBalance(uint256 _value) {
        uint256 nuevoTotal = s_totalDepositado + _value;
        if (nuevoTotal > i_bankCap) revert KipuBank_mayorAlBalance(nuevoTotal, i_bankCap);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _bankCap, uint256 _limiteExtraccionPorTx) {
        i_propietario = msg.sender;
        i_bankCap = _bankCap;
        i_limiteExtraccionPorTx = _limiteExtraccionPorTx;
    }

    /*//////////////////////////////////////////////////////////////
                             RECEIVE / FALLBACK
    //////////////////////////////////////////////////////////////*/

    receive() external payable {
        _deposito(msg.sender, msg.value);
    }

    fallback() external payable {
        if (msg.value > 0) {
            _deposito(msg.sender, msg.value);
        }
    }

    /*//////////////////////////////////////////////////////////////
                             EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function deposito() external payable noCero(msg.value) menorAlBalance(msg.value) {
        _deposito(msg.sender, msg.value);
    }

    function extraccion(uint256 _cantidad) external noCero(_cantidad) {
        if (_cantidad > i_limiteExtraccionPorTx) {
            revert KipuBank_LimiteExtraccionExcedido(_cantidad, i_limiteExtraccionPorTx);
        }
        uint256 bal = s_balances[msg.sender];
        if (_cantidad > bal) {
            revert KipuBank_BalanceInsuficiente(_cantidad, bal);
        }

        unchecked {
            s_balances[msg.sender] = bal - _cantidad;
            s_totalDepositado -= _cantidad;
        }
        s_numeroRetirosPorUsuario[msg.sender] += 1;
        s_extraccionesTotales += 1;

        _transferenciaSegura(msg.sender, _cantidad);

        emit KipuBank_Extraccion(msg.sender, _cantidad, s_balances[msg.sender]);
    }

    function getBalance(address _usuario) external view returns (uint256 balance) {
        return s_balances[_usuario];
    }

    /// @notice Devuelve el balance real en wei que tiene el contrato
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /*//////////////////////////////////////////////////////////////
                             PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _deposito(address _desde, uint256 _value) private noCero(_value) menorAlBalance(_value) {
        s_balances[_desde] += _value;
        s_numeroDepositosPorUsuario[_desde] += 1;
        s_depositosTotales += 1;
        s_totalDepositado += _value;

        emit KipuBank_Deposito(_desde, _value, s_balances[_desde]);
    }

    function _transferenciaSegura(address _para, uint256 _cantidad) private {
        (bool exito, bytes memory razon) = _para.call{value: _cantidad}("");
        if (!exito) revert KipuBank_TransferenciaFallida(razon);
    }
}
