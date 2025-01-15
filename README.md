# Lyneix AdrenalineRush Script
**Made with love and high caffeine by Lyneix_Team**


[Forum Post](https://forum.cfx.re/t/free-adrenaline-rush-script-lyneix-team/5296560).


# **🖤 Adrenaline Rush Script v1.3 Update 🖤**

---

### 🔄 **What's New in v1.3?**

---

### 🛠️ **Features & Improvements**
1. **New Config Option: `RestorePlayerStamina`**  
   - Decide whether the player's stamina should be restored during an adrenaline rush.  
   - Fully configurable in the `config.lua` file.  

2. **Revamped `Config.ByPassInjuryClipset`**  
   - Choose between two methods for handling ragdoll behavior:  
     - **Old Method**: Disable ragdoll, but note that it might cause some odd animations.  
     - **New Method**: For servers using `qb-ambulancejob`, automatically trigger an event to suppress injuries during adrenaline rush.  

3. **Optional Integration: `Config.Notify.UseOxLib`**  
   - Added support for `ox_lib` notifications.  
   - This feature is **optional** and works only if `ox_lib` is installed. No dependency headaches!  

4. **Version Update in `fxmanifest.lua`**  
   - Fixed the version text (oops, I’m still learning).  

---

### 🧹 **Code Improvements**
- **Refactored Code for Fallback Options**  
   - Restructured parts of the code to make it cleaner and easier to understand.  
   - Improved fallback mechanisms for better compatibility.  

---

### 📝 **How to Update**
1. Replace your current `lyneix_adrenalinerush` folder with the new version.  
2. Update your `server.cfg` if necessary:  
   ```plaintext
   ensure lyneix_adrenalinerush
3. Review the new configuration options in `config.lua`.
  * Make changes as needed to customize the script for your server.

---

### ❤️ **Thank You!**

This update is a result of your feedback and support. Keep it coming! 🙏

* Have questions or feedback? Drop a reply here or DM me.
* If you’re enjoying the script, share it with others!

**– Lyneix_Team**


"The original idea for this script came from my frustration with those dirt heads who think it’s hilarious to randomly ram people down with vehicles. Whether it’s intentional or just bad driving, the victim never stands a chance to fight back! So, I thought, why not give players the power of an action movie hero instead of leaving them helpless? And thus, the Adrenaline Rush Script was born. You’re welcome, humanity."

P.S. I’ve got what’s supposed to be a 9-to-5 job, but thanks to forced overtime, it’s more like 10 PM to 10 AM Bangkok time (GMT+7). My free time is limited, but I’ll still do my best to support you when I can—just bear with me if I’m running on caffeine and sheer determinatio

### 🔧 Installation
1. **Download the script**:
   - Clone the repository or [download it here](https://github.com/Liryuuu/lyneix_adrenalinerush).
2. **Add to your server**:
   - Place the `lyneix_adrenalinerush` folder in your server's `resources` directory.
3. **Update your `server.cfg`**:
   ```cfg
   ensure lyneix_adrenalinerush
4. **Optional Customization:**
    - Open config.lua and tweak settings like duration, effects, and notifications.
    
**⚙️ Configuration All settings can be customized in the config.lua file**

**Here are some key options:**
    - Duration: Set how long the adrenaline rush lasts.
    - Effects: Customize visual and gameplay effects like speed boost and invincibility.
    - Notifications: Use the default or integrate your own notification system.

**🤔 When to Use It**
High-octane events: Great for action-packed car chases or survival scenarios.
Unique gameplay moments: Surprise your players with an adrenaline boost when they least expect it.
Just for fun: Because who doesn’t love a little chaos?

**🛠️ Compatibility**
Frameworks Supported:ESX: Fully supported with framework-specific notifications.
QB-Core: Works seamlessly; requires additional setup for injury system invincibility if you want (DM for help!).
Standalone: No framework? No problem.
📝 License
This script is licensed under the MIT License.
Feel free to use, modify, and share it as long as proper credit is given to Lyneix_Team.

🙌 Support & Feedback
This is my first release!
If you encounter issues or have feedback, drop a message here or on the FiveM forums.

Give your players the adrenaline rush they deserve! 🚗💨
