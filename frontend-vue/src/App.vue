<script setup>
import { ref, onMounted } from "vue";
import { ethers, BrowserProvider, Contract } from "ethers";

const account = ref("");
const tickets = ref(0);
const numTickets = ref(1);
const contractBalance = ref("0");
const isOwner = ref(false);
const accountBalance = ref(0);
const contractSigner = ref(null);
const contractProvider = ref(null);

const contractAddress = "0x1210E02a41AA4856Ef16b5201DA0A1F5e60049fF"; // Địa chỉ contract
const abi = [
  "function tickets(address) view returns (uint)",
  "function ticketPrice() view returns (uint)",
  "function buyTicket(uint _numTickets) payable",
  "function withdraw()",
  "function owner() view returns (address)"
];

async function connectWallet() {
  if (!window.ethereum) {
    alert("Cài Metamask đi mày!");
    return;
  }

  try {
    // const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
    const provider = new BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    account.value = signer.address;

    const balance = await provider.getBalance(account.value);
    accountBalance.value = ethers.formatEther(balance);

    const network = await provider.getNetwork();
    const chainId = Number(network.chainId);

    if (chainId !== 10143) {
      try {
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: "0x27CF" }]
        });
      } catch (switchError) {
        if (switchError.code === 4902) {
          alert("Vui lòng thêm mạng Monad trước!");
        } else {
          throw switchError;
        }
      }
    }

    contractSigner.value = new Contract(contractAddress, abi, signer);
    contractProvider.value = new Contract(contractAddress, abi, provider);
    await checkOwner();
    await getTickets();
    if (isOwner.value) await getContractBalance();
  } catch (error) {
    console.error("Lỗi kết nối ví:", error);
    alert("Kết nối ví thất bại, thử lại đi mày!");
  }
}

async function getTickets() {
  try {
    if (contractProvider.value) {
      const userTickets = await contractProvider.value.tickets(account.value);
      tickets.value = userTickets.toString();
    }
  } catch (error) {
    console.error("Lỗi lấy số vé:", error);
  }
}

async function getContractBalance() {
  try {
    if (contractProvider.value) {
      const provider = new BrowserProvider(window.ethereum);
      const balance = await provider.getBalance(contractAddress);
      contractBalance.value = ethers.formatEther(balance);
    }
  } catch (error) {
    console.error("Lỗi lấy số dư contract:", error);
  }
}

async function checkOwner() {
  try {
    if (contractProvider.value) {
      const owner = await contractProvider.value.owner();
      isOwner.value = owner.toLowerCase() === account.value.toLowerCase();
    }
  } catch (error) {
    console.error("Lỗi kiểm tra owner:", error);
  }
}

async function buyTickets() {
  try {
    if (contractSigner.value) {
      const ticketPrice = await contractSigner.value.ticketPrice();
      const totalCost = ticketPrice * BigInt(numTickets.value);
      const tx = await contractSigner.value.buyTicket(numTickets.value, { value: totalCost });
      await tx.wait();
      alert("Mua vé thành công!");
      await getTickets();
      if (isOwner.value) await getContractBalance();
    }
  } catch (error) {
    console.error("Lỗi mua vé:", error);
    alert("Mua vé thất bại, kiểm tra MON đi mày!");
  }
}

async function withdraw() {
  try {
    if (contractSigner.value && isOwner.value) {
      const tx = await contractSigner.value.withdraw();
      await tx.wait();
      alert("Rút tiền thành công!");
      await getContractBalance();
    }
  } catch (error) {
    console.error("Lỗi rút tiền:", error);
    alert("Rút tiền thất bại, chỉ owner rút được!");
  }
}

function disconnectWallet() {
  account.value = "";
  tickets.value = 0;
  numTickets.value = 1;
  contractBalance.value = "0";
  isOwner.value = false;
  contract.value = null;
  alert("Đã hủy kết nối ví!");
}
</script>

<template>
  <div id="app" class="container">
    <div class="row justify-content-center">
      <div class="col-md-8">
        <h1 class="text-center mb-4">Mua vé trên Monad Testnet</h1>
        <div v-if="!account" class="text-center">
          <button @click="connectWallet" class="btn btn-primary btn-lg">Kết nối ví Metamask</button>
        </div>
        <div v-if="account" class="card p-4">
          <p class="mb-3"><strong>Địa chỉ ví:</strong> {{ account }}</p>
          <p class="mb-3"><strong>Số vé hiện tại:</strong> {{ tickets }}</p>
          <p class="mb-3"><strong>Số MON trong ví:</strong> {{ accountBalance }}</p>
          <p class="mb-3" v-if="isOwner"><strong>MON trong contract:</strong> {{ contractBalance }} MON</p>
          <div class="input-group mb-3">
            <input v-model.number="numTickets" type="number" class="form-control" placeholder="Số vé muốn mua"
              min="1" />
            <button @click="buyTickets" class="btn btn-success">Mua vé</button>
          </div>
          <button v-if="isOwner" @click="withdraw" class="btn btn-warning btn-block mb-3">Rút tiền</button>
          <button @click="disconnectWallet" class="btn btn-danger btn-block">Hủy kết nối ví</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
#app {
  margin-top: 50px;
}

h1 {
  color: #007bff;
  font-weight: bold;
}

.card {
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-primary {
  padding: 10px 20px;
  font-size: 1.2em;
}

.btn-success,
.btn-warning,
.btn-danger {
  font-size: 1em;
}

.input-group {
  max-width: 300px;
  margin: 0 auto;
}

.btn-block {
  width: 100%;
  margin-top: 10px;
}
</style>