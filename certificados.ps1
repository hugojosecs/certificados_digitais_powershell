cls
#MAPEIA O LOCAL 
net use B: /delete 
#Coloque abaixo o diretorio onde estão os certificados
net use B: "\\SERVIDOR\CERTIFICADO DIGITAL A1"

$caminho = "B:\"
$path = "B:\"


# FAZ A VARREDURA E SALVA O DIRETÓRIO
function EncontrarArquivos($diretorio){
    Set-Location $diretorio
    $arquivo = @(Get-ChildItem)
    return $arquivo
}


#BUSCA O CERTIFICADO NO DIRETORIO
function BuscaCert($caminho){
    
    $certificado = Get-ChildItem -Filter "*.pfx" -ErrorAction SilentlyContinue -Force
    return $certificado 
}

#BUSCA A SENHA SALVA NO ARQUIVO TXT NO DIRETORIO
function Senha($diretorio){
    Set-Location $path
    cd $diretorio
    $senha = Get-ChildItem -Filter "*SENHA*" -ErrorAction SilentlyContinue -Force
    try{
        $senhas = Get-Content $senha -ErrorAction SilentlyContinue -Force
        $senhas = $senhas.Trim()
    }catch{
        echo "Erro na leitura do:"+ $diretorio
     }
    return $senhas
}
#EXECUTA O COMANDO DE INSTALAÇÃO.
function InstalarCertificado($diretorio){
    $senhas = Senha($diretorio)
    $certificado = BuscaCert($diretorio)
    $dir = Get-Location
    cd c:\
    $certPath = [string]$dir+"\"+$certificado
    $certStore = “My”
    $certRootStore = “CurrentUser”
    
     try {
        #se tiver senha padrão, substitua o 12345678 pela sua senha padrão
        $pfxPass = ConvertTo-SecureString -String "12345678" -AsPlainText -Force
        $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
        $pfx.import($certPath,$pfxPass,"PersistKeySet") 
        $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore) 
        $store.open("MaxAllowed") 
        $store.add($pfx) 
        $store.close() 
        echo "Certificado $certificado instalado"
    } catch {
        $pfxPass = ConvertTo-SecureString -String "$senhas" -AsPlainText -Force
        try {
            $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 
            $pfx.import($certPath,$pfxPass,"PersistKeySet") 
            $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore) 
            $store.open("MaxAllowed") 
            $store.add($pfx) 
            $store.close() 
            echo "Certificado $certificado instalado usando senha personalizada"

        } catch{
            echo "------------------"
            echo "erro $certificado"
            echo "------------------"
        }
    
    
    }
        
    
    
}
#ATRIBUI O RESULTADO DO DIRETORIO
$diretorios = EncontrarArquivos($caminho)

#REPETIÇÃO DE TODOS OS ARQUIVOS DENTRO DO RESULTADO DA VARIAVEL ACIMA
if ($diretorios -ne "[]"){
    foreach ($dir in $diretorios){
        InstalarCertificado($dir)
}
} else {
    echo "----------------"
    echo "Sem resultado"
    echo "----------------"
}
cd c:\
net use B: /delete 
pause



