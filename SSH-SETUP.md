# SSH Key Setup Guide for Windows

## SSH Key Storage Locations

### Windows (Native)
- **Directory**: `C:\Users\<YourUsername>\.ssh\`
- **Private Key**: `C:\Users\<YourUsername>\.ssh\id_rsa`
- **Public Key**: `C:\Users\<YourUsername>\.ssh\id_rsa.pub`

### WSL (Windows Subsystem for Linux)
- **Directory**: `/home/<username>/.ssh/`
- **Private Key**: `/home/<username>/.ssh/id_rsa`
- **Public Key**: `/home/<username>/.ssh/id_rsa.pub`

### Git Bash
- **Directory**: `~/.ssh/` (resolves to Windows user directory)
- **Private Key**: `~/.ssh/id_rsa`
- **Public Key**: `~/.ssh/id_rsa.pub`

## How to Generate SSH Keys

### Option 1: Windows PowerShell/Command Prompt
```powershell
# Create .ssh directory if it doesn't exist
mkdir %USERPROFILE%\.ssh

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f %USERPROFILE%\.ssh\id_rsa -C "your-email@example.com"
```

### Option 2: WSL (Recommended)
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -C "your-email@example.com"
```

### Option 3: Git Bash
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -C "your-email@example.com"
```

## Configuring Terraform

### Default Configuration
The default path in `terraform.tfvars` is:
```hcl
ssh_public_key_path = "~/.ssh/id_rsa.pub"
```

### Custom Path Examples
If your SSH key is in a different location, update `terraform.tfvars`:

```hcl
# Windows absolute path
ssh_public_key_path = "C:/Users/YourUsername/.ssh/id_rsa.pub"

# WSL path (if running Terraform from WSL)
ssh_public_key_path = "/home/username/.ssh/id_rsa.pub"

# Custom key name
ssh_public_key_path = "~/.ssh/n8n_key.pub"
```

## Verifying Your SSH Key

### Check if SSH key exists
```powershell
# Windows PowerShell
dir %USERPROFILE%\.ssh\

# WSL/Git Bash
ls -la ~/.ssh/
```

### View public key content
```powershell
# Windows PowerShell
type %USERPROFILE%\.ssh\id_rsa.pub

# WSL/Git Bash
cat ~/.ssh/id_rsa.pub
```

## SSH Key Permissions (Important for WSL/Linux)

If using WSL, set correct permissions:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

## Testing SSH Connection

After deployment, test SSH connection:
```bash
# Get the public IP from Terraform output
terraform output ec2_public_ip

# SSH to the instance
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>

# Or use the provided SSH command
terraform output ssh_command
```

## Troubleshooting

### Common Issues

1. **"No such file or directory"**
   - SSH key doesn't exist at the specified path
   - Generate SSH key or update the path in terraform.tfvars

2. **"Permission denied (publickey)"**
   - Wrong SSH key path
   - Incorrect key permissions (WSL/Linux)
   - Key not properly uploaded to EC2

3. **"Bad permissions"**
   - SSH key permissions too open (WSL/Linux only)
   - Run: `chmod 600 ~/.ssh/id_rsa`

### Path Resolution
- `~` resolves to different locations depending on your environment
- Use absolute paths if you encounter issues
- Ensure forward slashes `/` in paths, even on Windows

## Security Best Practices

1. **Never share your private key** (`id_rsa`)
2. **Use strong passphrases** when generating keys
3. **Keep private keys secure** with proper file permissions
4. **Use different keys** for different environments/projects
5. **Regularly rotate keys** for production environments