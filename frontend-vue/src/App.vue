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
          <div class="input-group mb-3">
            <input v-model.number="numTickets" type="number" class="form-control" placeholder="Số vé muốn mua"
              min="1" />
            <button @click="buyTickets" class="btn btn-success">Mua vé</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';

export default {
  name: 'App',
  data() {
    return {
      account: '',
      tickets: 0,
      numTickets: 1,
      contractAddress: '0x1210E02a41AA4856Ef16b5201DA0A1F5e60049fF',
      abi: [
        'function tickets(address) view returns (uint)',
        'function ticketPrice() view returns (uint)',
        'function buyTicket(uint _numTickets) payable'
      ],
      contract: null
    };
  },
  methods: {
    async connectWallet() {
      try {
        if (!window.ethereum) {
          alert('Cài Metamask đi mày!');
          return;
        }

        // Kết nối Metamask
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const provider = new ethers.BrowserProvider(window.ethereum);
        const signer = await provider.getSigner();
        this.account = accounts[0];
        // Kiểm tra mạng hiện tại
        const network = await provider.getNetwork();

        if (network.chainId !== 10143) {
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0x27CF' }]
            });
          } catch (switchError) {
            if (switchError.code === 4902) {
              alert('Vui lòng thêm mạng Monad trước!')              
            } else {
              throw switchError;
            }
          }
        }

        // Kết nối contract
        this.contract = new ethers.Contract(this.contractAddress, this.abi, signer);
        await this.getTickets();
      } catch (error) {
        console.error('Lỗi kết nối ví:', error);
        alert('Kết nối ví thất bại, thử lại đi mày!');
      }
    },

    async getTickets() {
      try {
        if (this.contract) {
          const tickets = await this.contract.tickets(this.account);
          this.tickets = tickets.toString();
        }
      } catch (error) {
        console.error('Lỗi lấy số vé:', error);
      }
    },

    async buyTickets() {
      try {
        if (this.contract) {
          const ticketPrice = await this.contract.ticketPrice();
          const totalCost = BigInt(ticketPrice) * BigInt(this.numTickets);

          const tx = await this.contract.buyTicket(this.numTickets, { value: totalCost });
          await tx.wait();

          alert('Mua vé thành công!');
          await this.getTickets();
        }
      } catch (error) {
        console.error('Lỗi mua vé:', error);
        alert('Mua vé thất bại, kiểm tra MON đi mày!');
      }
    }
  }
};
</script>


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

.btn-success {
  font-size: 1em;
}

.input-group {
  max-width: 300px;
  margin: 0 auto;
}
</style>