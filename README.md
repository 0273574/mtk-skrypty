# MikroTik Security and Administration Scripts

This repository contains automated scripts for MikroTik devices to enhance security settings, perform regular backups, monitor login activity, and keep RouterOS software up to date.

> **Tested on RouterOS v7.18.2**

---

## 🛡️ Overview

This set of scripts automates several critical network administration tasks:

- **Security hardening** of MikroTik devices  
- **Automated version checking and updating** of RouterOS  
- **Regular system backups**  
- **Login monitoring and email alerts**

---

## ⚙️ How It Works

The main script (`skrypty_update`) is downloaded from a web server. It checks the current version installed on the device, and if a newer version is found, it replaces and imports it automatically.

### Features:

- Automatic update detection and import
- Scheduled tasks for maintenance
- Email notifications for events like updates, backups, or login activity

---

## 🔐 Core Components

### 🔒 Security Hardening

- Changes the default **WinBox** port
- Disables unnecessary services
- Creates a new administrative user
- Disables the default `admin` user

### 🔄 Software Updates

- Checks for RouterOS updates
- Downloads available updates
- Sends notifications via email

### 💾 System Backup

- Creates regular backups
- Sends backups via email
- Manages and cleans up old backup files

### 🧾 Login Monitoring

- Tracks both successful and failed login attempts
- Generates reports
- Sends email alerts with login details

---

## 📦 Installation

1. Create a file named `script.rsc` on your web server with the content from `script.rsc` in this repository you have to edit `mail@mail.pl` in this file for e-mail where do you want to sent notifications. (version used: **v0.4**)
2. Edit `pobieranie_aktualizacji` to include your configuration:
   ```rsc
   :local mail "your-email@example.com"
   :local mailpassword "your-email-password"
   :local winboxPort "your-preferred-port"
   :local newUsername "your-new-admin-username"
   :local newPassword "your-new-admin-password"
   /tool fetch url="http://YOUR-SERVER-IP/script.rsc" mode=http dst-path="downloaded_script.rsc"
   ```
   
3. Create new script in Mikrotik, paste modified `pobieranie_aktualizacji` and run it, check logs if something doesn't work corretly.

### What it does:

- Configures DNS and NTP
- Sets up email notifications
- Downloads the main script from your server
- Applies security settings
- Schedules regular updates and maintenance

---

## ⏲️ Scheduled Tasks

The system automatically creates these scheduled tasks:

| Task Name              | Function                      | Frequency        |
|------------------------|-------------------------------|------------------|
| `skrypty-scheduler`    | Checks for script updates      | Weekly           |
| `soft_update-scheduler`| Checks for RouterOS updates    | Weekly           |
| `backup-scheduler`     | Performs system backups        | Monthly          |
| `login`                | Monitors login activity        | Every 6 hours    |

---

## 🧩 Version Control

Each script has a version (e.g., `v0.4`). During scheduled checks, devices will detect and apply newer versions if available on the web server.

---

## 🔐 Security Considerations

- **Email credentials are stored in plaintext** — use a dedicated email account.
- **All services except WinBox are disabled** by default for security.
- It's **recommended to restrict WinBox access** via firewall rules.

---

## 📋 Requirements

- MikroTik device with **RouterOS v7.x** (tested on **7.18.2**)
- A web server to host `script.rsc`
- Email account for notifications

---

## 📝 License

This project is provided **as-is** without any warranty. Use at your own risk.
