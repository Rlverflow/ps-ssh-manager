# ps-ssh-manager
A robust, lightweight, and "idiot-safe" PowerShell-based SSH connection manager. Built for developers who switch between Linux based OS and Windows environments and need a reliable way to keep their rigs organized.
# Features
*Cross-Platform Support: Dedicated tagging for Windows [W] and Linux [L] machines.

*Collision-Proof: Uses unique GUIDs for every server entry—no more bugs when deleting servers with duplicate names.

*Bulletproof Logic: Sanitized inputs (no accidental space bugs) and strict error handling.

*Session Security: Integrated connection timeouts to prevent the script from hanging on dead hosts.

*Automatic Logging: Tracks every connection attempt, addition, and removal in .\logs\manager.log.

*Portable: Everything is stored in a simple servers.json file. Move the folder, and your config stays with you.

#🛠️ Installation
1-Clone the repository:
<img width="551" height="75" alt="image" src="https://github.com/user-attachments/assets/1863bd52-6e6c-4308-a3e5-6798a7c2937a" />
2-Set Execution Policy (if needed):

If PowerShell blocks the script, run:
<img width="599" height="39" alt="image" src="https://github.com/user-attachments/assets/4951283c-36b1-467e-95e0-bdb1f6f8de4f" />
3-Run the Manager:
<img width="702" height="59" alt="image" src="https://github.com/user-attachments/assets/739813f0-ec2f-4c26-9f62-04b2ecfb000c" />

# 🖥️ Usage
1-Number (1-N)	:  Initiates an SSH session to the corresponding server.

2-[a] Add	      :  Interactive wizard to add a new rig (Nickname, IP, User, OS).

3-[r] Remove	  :  Safely delete a server from your list by its index.

4-[l] Logs	    :  View the last 20 lines of activity.

5-[v] Info	    :  View version and developer details.

6-[q] Quit	      :  Safely exit the manager.

# ⚙️ Target Machine Setup

To ensure you can connect to your machines, make sure SSH is enabled on the target:

For Linux:

<img width="463" height="72" alt="image" src="https://github.com/user-attachments/assets/42cc37ab-6fee-45ff-adfd-8468fc848c4b" />

for windows:

Run Powershell as Administrator:

<img width="548" height="82" alt="image" src="https://github.com/user-attachments/assets/9036aa4a-da90-45a0-885c-a21f4b271754" />

# 🛡️ Stability Status: V1.5.4 (Stable)

This version has been "Sunday Roasted"—tested for input errors, parser bugs, and network timeouts.

Developed by Rlverflow
