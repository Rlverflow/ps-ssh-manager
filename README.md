# 💻 ssh-manager

A robust, lightweight, and **idiot-safe** cross-platform SSH connection manager. Built for developers and sysadmins who move between **Linux**, **Windows**, and **BSD** environments and need a reliable, portable way to keep their servers organized.

---

## 🌟 Features

* **Cross-Platform Tagging:** Dedicated OS identifiers for Windows `[W]`, Linux `[L]`, and BSD `[B]` targets.
* **Multi-Shell Native:** Native implementations for **PowerShell**, **Bash**, and POSIX **`sh`** (for minimal BSD/Linux environments without Bash pre-installed).
* **Collision-Proof Storage:** Uses unique GUIDs for every server entry—no name-collision bugs when deleting duplicate hosts.
* **Bulletproof Logic:** Sanitized inputs (no whitespace or parsing errors) paired with strict error handling.
* **Session Security:** Integrated connection timeouts prevent script hangs on dead or unreachable hosts.
* **Automatic Audit Logging:** Tracks every connection attempt, addition, and removal in `logs/manager.log`.
* **Zero-Dependency Portability:** Everything is stored in a simple `servers.json` file. Move the directory, and your configuration moves with you.

---

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Rlverflow/ssh-manager.git
cd ssh-manager
```

### 2. Set Execution Policy (Windows PowerShell)

If PowerShell restricts script execution on Windows, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Run the Manager

#### Windows (PowerShell)

```powershell
.\ssh-manager.ps1
```

#### Linux & BSD (Bash)

```bash
chmod +x ssh-manager.sh
./ssh-manager.sh
```

#### BSD & Minimal Linux (POSIX `sh`)

```sh
chmod +x ssh-manager.sh
./ssh-manager.sh
```

---

## 🖥️ Usage

When launched, `ssh-manager` opens an interactive console interface:

| Option | Command | Description |
| :---: | :--- | :--- |
| **`1-N`** | Connect | Initiates an SSH session to the corresponding server index |
| **`a`** | Add | Interactive wizard to add a new rig (Nickname, IP, User, OS) |
| **`r`** | Remove | Safely delete a server entry by its index |
| **`l`** | Logs | View the last 20 lines of connection activity |
| **`v`** | Info | Display version information and developer details |
| **`q`** | Quit | Safely exit the manager |

---

## ⚙️ Target Machine Setup

Ensure SSH service is enabled on target host machines prior to connecting:

### 🐧 Linux

```bash
sudo systemctl enable --now sshd
```

### 😈 BSD (FreeBSD / NetBSD / OpenBSD)

```sh
# FreeBSD
sysrc sshd_enable="YES"
service sshd start

# NetBSD
echo 'sshd=YES' >> /etc/rc.conf
/etc/rc.d/sshd start

# OpenBSD (enabled by default)
rcctl enable sshd
rcctl start sshd
```

### 🪟 Windows (Run PowerShell as Administrator)

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

---

## 🛡️ Stability Status: `v1.5.6` (Stable)

This release has been thoroughly tested for input edge cases, JSON parsing integrity, network timeout recovery, and feature parity across Bash, POSIX `sh`, and PowerShell execution environments.

**Developer:** [Rlverflow](https://github.com/Rlverflow)
