# Guia: Fazer Login no GitHub e Subir o Projeto

## 1️⃣ Gerar Token de Autenticação (GitHub)

### No GitHub.com:

1. Acesse: https://github.com/settings/tokens
2. Clique em **"Generate new token"** > **"Generate new token (classic)"**
3. Configure:
   - **Note**: "SmartGridElixir Local Development"
   - **Expiration**: 90 dias (ou conforme preferência)
   - **Select scopes**: Marque:
     - ☑️ `repo` (full control)
     - ☑️ `workflow` (se usar GitHub Actions)
4. Clique em **"Generate token"**
5. **Copie o token** (você só verá uma vez!)

## 2️⃣ Configurar Git Localmente

```powershell
# Configurar identidade global
git config --global user.name "Lucas"
git config --global user.email "seu-email@github.com"

# Configurar credenciais (Windows)
git config --global credential.helper wincred

# Ou armazenar em arquivo
git config --global credential.helper store
```

## 3️⃣ Criar Repositório no GitHub

1. Acesse: https://github.com/new
2. **Repository name**: `SmartGridElixir`
3. **Description**: "Smart Grid billing system with Elixir - Immutable pipelines, pattern matching, statistical analysis"
4. **Visibility**: Public ou Private (sua escolha)
5. **Initialize repository**: ❌ (Não marcar - já temos commits)
6. Clique **"Create repository"**

## 4️⃣ Conectar Repositório Local ao GitHub

Após criar o repositório, você verá as instruções. Execute:

```powershell
cd "c:\Users\lucas\Documents\CarrinhoArduino"

# Adicionar remote origin
git remote add origin https://github.com/SEU_USERNAME/SmartGridElixir.git

# Renomear branch main (se necessário)
git branch -M main

# Enviar commits para GitHub
git push -u origin main
```

### Na primeira vez:

O Git pedirá suas credenciais:
```
Username for 'https://github.com': SEU_USERNAME
Password for 'https://SEU_USERNAME@github.com': COLE_O_TOKEN_AQUI
```

Depois, as credenciais serão armazenadas automaticamente.

## 5️⃣ Verificar Conexão

```powershell
git remote -v
```

Saída esperada:
```
origin  https://github.com/SEU_USERNAME/SmartGridElixir.git (fetch)
origin  https://github.com/SEU_USERNAME/SmartGridElixir.git (push)
```

## 6️⃣ Próximos Commits (Automático)

Depois que configurar, é só:

```powershell
git add .
git commit -m "Sua mensagem aqui"
git push
```

## 🔐 Alternativa: Usar SSH (Mais Seguro)

```powershell
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu-email@github.com"
# Pressione Enter para tudo

# Copiar chave pública
type $env:USERPROFILE\.ssh\id_ed25519.pub | clip

# Colar em https://github.com/settings/keys (New SSH key)

# Testar conexão
ssh -T git@github.com
# Resposta esperada: "Hi USERNAME! ..."

# Mudar URL do repositório para SSH
git remote set-url origin git@github.com:SEU_USERNAME/SmartGridElixir.git
```

## ✅ Checklist

- [ ] Token gerado no GitHub
- [ ] Identidade Git configurada globalmente
- [ ] Repositório criado no GitHub
- [ ] Remote origin adicionado
- [ ] Primeiro push feito com sucesso
- [ ] Credenciais armazenadas (ou SSH configurado)

## 🆘 Troubleshooting

### "fatal: could not read Username"

Solução:
```powershell
git config --global credential.helper wincred
# Depois tente fazer push novamente
```

### "remote: Repository not found"

Verificar:
- [ ] URL está correta
- [ ] Repositório existe no GitHub
- [ ] Você tem permissão

### "fatal: 'origin' does not appear to be a 'git' repository"

```powershell
git remote add origin https://github.com/SEU_USERNAME/SmartGridElixir.git
```

## 📚 Referências

- [GitHub Docs - Creating a token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
- [Git - remote](https://git-scm.com/docs/git-remote)
- [GitHub - Getting Started](https://docs.github.com/en/get-started)
