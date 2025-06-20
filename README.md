# **OSRS-Discord-Game-Chat-Logger**

This Python script is designed to connect to a Discord server, fetch messages from a specific channel (typically containing game chat and broadcast messages from Old School RuneScape), parse them using a flexible regex engine, and store the structured data in a database.  
The project is built to be highly configurable, supporting both local SQLite databases for easy setup and remote PostgreSQL databases (like Supabase) for more robust, scalable deployments.

## **Primary Use Case: Clan Dashboards**

The main purpose of this project is to collect and structure clan activity data to create powerful, interactive dashboards. By parsing game messages, you can visualize your clan's progress, achievements, and events over time.  
This project includes **Streamlit** as a dependency, which is a fantastic Python library for building data apps. Once you have data in your database, you can create a simple Streamlit script to build and host a dashboard showing:

* **Leaderboards**: Top PvMers, skillers, or clue hunters.  
* **Recent Activity**: A live feed of the latest valuable drops, pet acquisitions, and 99s.  
* **Item Showcase**: A gallery of the most valuable drops your clan has received.  
* **PK Log**: A list of the biggest player kills, showing who defeated whom and for how much loot.  
* **Collection Log Progress**: Tracking who is getting new unique items.  
* **Personal Bests**: Celebrating new speedrun records for bosses.

## **Features**

* **Discord Integration**: Fetches message history from a specified Discord channel within a defined time range.  
* **Advanced Regex Parsing**: Uses a TOML configuration file to define complex regex patterns for parsing different message types (e.g., chat, drops, achievements).  
* **Flexible Database Support**:  
  * **SQLite**: Easy, file-based local database for quick setup and testing.  
  * **PostgreSQL**: Supports remote databases like Supabase for production use.  
* **Automated Reporting**: Generates detailed CSV reports and logs for each run, including parsed data and any messages that failed to parse.  
* **State Management**: Keeps track of the last successful run to only fetch new messages, preventing data duplication.  
* **Regex Testing Utility**: Includes a separate script to rapidly test and refine your regex patterns against a raw dump of messages.  
* **Home Assistant Integration**: Can be easily automated to run on a schedule using Home Assistant's shell\_command integration.

## **Core Dependency: RuneLite Plugin**

This script is specifically designed to parse messages generated by the [**Clan Chat Webhook**](https://runelite.net/plugin-hub/show/clan-chat-webhook) plugin for the RuneLite client.  
**This is a hard requirement.** For the parsing to work correctly, you must:

1. Install the "Clan Chat Webhook" plugin from the RuneLite Plugin Hub.  
2. Configure the plugin to send messages to a specific webhook in your Discord server.  
3. The Discord channel that this script reads from (specified by discord\_data\_channel\_id in your secrets.toml) **should exclusively contain messages from this webhook.** Other chat or bot messages in this channel will cause parsing errors.

## **Folder and file structure**
📁 OSRS-Discord-Game-Chat-Logger/  
├── .gitignore               \# Specifies files to ignore for Git  
├── README.md                \# This file  
├── install\_dependencies.bat \# Script to install Python packages  
├── run\_sync.bat             \# Main script to run the data sync  
├── data/                    \# (Generated) For database files and run state  
├── reports/                 \# (Generated) For CSV reports and run logs  
└── src/  
....├── main.py                  \# The main Python script  
....├── config.toml              \# Main configuration for patterns, timings, etc.  
....├── secrets.example.toml     \# Template for your secret keys  
....└── regex\_test/  
........├── run\_regex\_test.bat   \# Script to run the regex tester  
........└── regex\_test.py        \# The regex testing utility

## **Setup and Installation**

### **1\. Prerequisites**

* [Python 3.8+](https://www.python.org/downloads/)  
* [Git](https://git-scm.com/downloads/)  
* [RuneLite](https://runelite.net/) with the [Clan Chat Webhook](https://runelite.net/plugin-hub/show/clan-chat-webhook) plugin installed.

### **2\. Clone the Repository**

Clone this repository to your local machine:  
git clone \<your-repo-url\>  
cd OSRS-Discord-Game-Chat-Logger

### **3\. Create a Virtual Environment (Recommended)**

Using a virtual environment keeps your project's dependencies isolated.  
\# Create the virtual environment  
python \-m venv venv

\# Activate it  
\# On Windows:  
venv\\Scripts\\activate  
\# On macOS/Linux:  
source venv/bin/activate

### **4\. Install Dependencies**

Run the provided batch script to install all the necessary Python libraries from requirements.txt.  
install\_dependencies.bat

### **5\. Configure Secrets**

Your secret keys (like your Discord Bot Token) are now managed in a separate file to keep them secure.

1. Navigate to the src/ directory.  
2. **Rename secrets.example.toml to secrets.toml**.  
3. Open secrets.toml with a text editor and fill in your details:  
   * discord\_bot\_token: Your private Discord bot token.  
   * discord\_data\_channel\_id: The ID of the Discord channel that the RuneLite plugin is sending messages to.  
   * discord\_log\_channel\_id: The channel where the script will post a summary after each run.  
   * database\_uri: The connection string for your database. Examples for both SQLite and Supabase are provided.

### **6\. Review General Configuration**

Open src/config.toml to configure the script's behavior, such as time settings, report cleanup, and most importantly, the **regex parsing patterns**. The default patterns are designed for the Clan Chat Webhook plugin, but you can adjust them if needed.

## **How to Use**

### **Running the Main Sync Script**

Once everything is configured, simply run the batch file from the project's root directory:  
run\_sync.bat

This will start the process of fetching, parsing, and saving the data. A new folder will be created in the /reports directory containing CSV files and a detailed log of the run.

### **Using the Regex Testing Utility**

This tool is incredibly useful for refining your regex patterns without the delay of running the full script.  
**Workflow:**

1. In src/config.toml, set debug\_mode \= true.  
2. Run the main script (run\_sync.bat). This will generate a file named raw\_message\_dump.txt inside the latest folder in /reports. This file contains the cleaned content of every message fetched in that run.  
3. **Copy raw\_message\_dump.txt** from the reports folder and **paste it into the src/regex\_test/ directory.**  
4. Navigate into the src/regex\_test/ directory and run the tester:  
   run\_regex\_test.bat

5. The script will test every line from the dump file against your patterns in config.toml.  
6. A log file, regex\_test\_failures.log, will be created in the same directory, detailing every message that failed to parse and why. This allows you to quickly identify and fix your regex patterns.

## **Home Assistant Automation**

You can automate this script to run on a schedule using Home Assistant. This is done by adding a shell\_command to your configuration.yaml file.  
**Prerequisites on your Home Assistant machine:**

* The project files must be accessible.  
* Python 3 must be installed.  
* All dependencies from requirements.txt must be installed for the user that Home Assistant runs as.

### **1\. Add to configuration.yaml**

Add the following to your configuration.yaml file in Home Assistant. **Make sure to update the path** to where you've stored the project.  
shell\_command:  
  run\_discord\_chat\_logger: '/usr/bin/python3 /path/to/your/project/OSRS-Discord-Game-Chat-Logger/src/main.py'

*Note: The path to python3 might be different on your system (e.g., for Home Assistant OS). You may need to use python instead of python3.*

### **2\. Create an Automation**

In Home Assistant, go to **Settings \> Automations & Scenes** and create a new automation. You can trigger it based on time.  
**Example Automation (run daily at 3:00 AM):**

* **Trigger Type**: Time  
* **Time**: 03:00:00  
* **Action Type**: Call service  
* **Service**: shell\_command.run\_discord\_chat\_logger

Now, Home Assistant will automatically execute your script every day at 3 AM. The script will use its sync\_state.json file to pick up where it left off.
