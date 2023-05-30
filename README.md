# SLDT AZURE 환경 구성
 목적 : SLDT 고객사의 Vault Usecase 테스트 용도로 AZURE 인프라 환경을 테라폼으로 구성한 코드입니다.

<br>

## 전제 조건 (Prerequisites)
1. Terraorm 환경 구성
    <br>

    해당 코드를 실행하기 위해서는 Terraform을 실행할 수 있는 환경이 필요합니다. ( Terraform Cli install : https://www.terraform.io/downloads.html )
<br>

2. ssh-key 생성
    ```shell
    $ ssh-keygen -t rsa -b 2048
    ```
    해당 명령어를 실행한 뒤 public key를 해당 코드의 'sshkey' 디렉토리 하위에 넣습니다.
    <br>
    해당 코드의 vm들은 모두 ssh key 방식으로 접속하며, 'sshkey' 디렉토리 하위의 public key를 기반으로 생성됩니다.

3. Azure Service Principal 
   <br>

   Service Principal은 인증에 사용할 수 있는 Azure Active Directory 내의 응용 프로그램입니다. 
   <br>
   Terraform Azure Provider를 사용하기 위해 Azure Service Principal을 준비합니다.
   <br>
   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
   <br>
   - **Subscription ID**
   - **Tenant ID**
   - **Client ID**
   - **Client secret**
   <br>




<br>

# Azure Key Vault를 사용한 Auto-unseal

## Auto-unseal Steps

1. Vault VM에 접속해서 vault.hcl파일에 다음 내용을 추가합니다.
    ```shell
    seal "azurekeyvault" {
      tenant_id      = "tenant_id 기입"
      client_id      = "client_id 기입"
      client_secret  = "client_secret 기입"
      vault_name     = "output vault_name 참조 후 기입"
      key_name       = "output key_name 참조 후 기입"
   }
    ```

1. Vault 재기동 후 Vault Status 를 확인합니다.

    ```text
    $ vault status
    Key                      Value
    ---                      -----
    Recovery Seal Type       azurekeyvault
    Initialized              false
    Sealed                   true
    Total Recovery Shares    0
    Threshold                0
    Unseal Progress          0/0
    Unseal Nonce             n/a
    Version                  n/a
    HA Enabled               false
    ```


1. Initialize Vault

    ```plaintext
    $ vault operator init -recovery-shares=5 -recovery-threshold=3 | tee /root/vault-initialization.txt

    Recovery Key 1: U3rgjytYcASCk3N0s30Hl8R4ydSANxlgEcuxlHbbqcjw
    Recovery Key 2: wfIClA3BGKsUCIzguAsz179SdqRsSznwA1FNFm9KTV5c
    Recovery Key 3: NTBrsaFM4/5ccgdX4rqHSZfh9fH4QA/+mhdZL0I07erc
    Recovery Key 4: QrxTE11hWDcivoavwsz87mQ51ubXxEgTlSGm5lPvSDtG
    Recovery Key 5: 6liLPELe/FQxfL2hWuizHiSHr4EvIyqak1+B4GmnFFRs

    Initial Root Token: hvs.LdLOUTM1hbDdjEKAa8hHAk8C

    Success! Vault is initialized

    Recovery key initialized with 5 key shares and a key threshold of 3. Please
    securely distribute the key shares printed above.
    ```

1. Vault Service를 재시작합니다.

    ```shell
    $ sudo systemctl restart vault
    ```

1. vault status 명령어를 통해 auto-unsealed 되었는지 확인합니다.

    ```text
    $ vault status
    Key                      Value
    ---                      -----
    Recovery Seal Type       shamir
    Initialized              true
    Sealed                   false
    Total Recovery Shares    5
    Threshold                3
    Version                  1.5.0
    Cluster Name             vault-cluster-092ba5de
    Cluster ID               8b173565-7d74-fe5b-a199-a2b56b7019ee
    HA Enabled               false
    ```

1. Explore the Vault configuration file

    ```plaintext
    $ sudo cat /etc/vault.d/vault.hcl

    ui = true
    disable_mlock = true

    api_addr = "http://VAULT-IP-ADDRESS:8200"
    cluster_addr = "http://VAULT-IP-ADDRESS:8201"

    storage "file" {
      path = "/opt/vault/data"
    }

    listener "tcp" {
      address         = "0.0.0.0:8200"
      cluster_address = "0.0.0.0:8201"
      tls_disable     = 1
      telemetry {
        unauthenticated_metrics_access = true
      }
    }

    # enable the telemetry endpoint.
    # access it at http://<VAULT-IP-ADDRESS>:8200/v1/sys/metrics?format=prometheus
    # see https://www.vaultproject.io/docs/configuration/telemetry
    # see https://www.vaultproject.io/docs/configuration/listener/tcp#telemetry-parameters
    telemetry {
      disable_hostname = true
      prometheus_retention_time = "24h"
    }

    # enable auto-unseal using the azure key vault.
    seal "azurekeyvault" {
      client_id      = "YOUR-AZURE-APP-ID"
      client_secret  = "YOUR-AZURE-APP-PASSWORD"
      tenant_id      = "YOUR-AZURE-TENANT-ID"
      vault_name     = "Test-vault-xxxx"
      key_name       = "generated-key"
    }
    ```

<br>


# Azure blob storage 를 사용한 Vault autobackup

## Auto-backup Steps

1. Vault Server에 접속하여 root token을 사용해 Vault에 login합니다.

    ```plaintext
    $ vault login hvs.LdLOUTM1hbDdjEKAa8hHAk8C
    ```

1. 다음과 같이 Auto-backup 기능을 활성화합니다.

    ```plaintext
    $ vault write sys/storage/raft/snapshot-auto/config/bak-blob \
      interval=3m \
      retain=3 \
      storage_type=azure-blob \
      azure_container_name=${Storage Container Name} \
      azure_account_name=${Service Account Name} \
      azure_account_key=${Service Account Key} \
      azure_blob_environment=AzureCloud
    ```


<br>


## Clean up

실습을 마쳤다면 destroy 명령어를 통해 해당 리소스들을 삭제합니다.

```plaintext
$ terraform destroy -auto-approve

$ rm -rf .terraform terraform.tfstate*
```
