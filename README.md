# 🏦 KipuBank

Un contrato inteligente escrito en **Solidity** que implementa una bóveda de depósitos y retiros de ETH con límites configurables.

Este proyecto forma parte de un examen práctico de desarrollo Web3 y está diseñado con fines educativos.

---

## ✨ Funcionalidad

* Los usuarios pueden **depositar ETH** en su bóveda personal.
* Cada usuario puede **retirar ETH** hasta un límite fijo por transacción.
* Existe un **límite global de depósitos (bankCap)** configurado al desplegar el contrato.
* Se lleva registro de:

  * Saldos individuales.
  * Número de depósitos y retiros por usuario.
  * Total de depósitos y retiros del banco.
  * ETH acumulado en todo el contrato.
* Se emiten **eventos** en cada depósito y extracción.
* Se aplican **errores personalizados** y buenas prácticas de seguridad.

---

## 📂 Estructura del proyecto

```
/contracts
 └── KipuBank.sol
README.md
```

---

## 🚀 Despliegue en Remix

1. Abrir [Remix IDE](https://remix.ethereum.org/).
2. Crear un nuevo archivo en `/contracts` llamado `KipuBank.sol`.
3. Copiar el contenido del contrato.
4. Compilar con la versión `0.8.25`.
5. En la sección **Deploy & Run**, seleccionar el entorno:

   * `Remix VM` (local)
   * o inyectar `MetaMask` para desplegar en testnet (ej. Sepolia).
6. Ingresar los parámetros del constructor:

   * `_bankCap` → límite global (ej: `100 ether`).
   * `_limiteExtraccionPorTx` → límite máximo por extracción (ej: `1 ether`).
7. Hacer **Deploy**.

---

## 🛠️ Interacción

* **deposito()** → permite depositar ETH (usar el campo "Value" en Remix).
* **extraccion(uint256 _cantidad)** → retira ETH de la cuenta del usuario (hasta el límite configurado).
* **getBalance(address usuario)** → devuelve el balance individual.
* **contractBalance()** → devuelve el balance total del contrato en wei.

---

## 🔒 Seguridad y buenas prácticas

* Uso de **errores personalizados** en lugar de `require` con strings.
* Patrón **checks-effects-interactions**.
* Variables `immutable` y `public` para mayor transparencia.
* Funciones `private` para encapsular lógica interna.
* Protección contra reentradas con **nonReentrant**.
* Documentación completa con **NatSpec**.

---

## 🔗 Contrato en el Block Explorer

👉 Ver en [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x1A9fD8a2064c67Cc8Ae8046c2b71724C570B6a87)


---
