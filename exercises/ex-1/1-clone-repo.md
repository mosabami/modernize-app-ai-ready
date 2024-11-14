# Task 01 - Clone the GitHub repository for the project to your local machine

Now that you have completed the first time of the lab, we will be moving on to the second part of the lab where you will learn how to:
1. Decompose a monolithic app into two components (can be considered microservices but in this case we keep it simple by breaking it into frontend and backend services)
1. Containerize the services and push the container images to the cloud
1. Create container services in Azure container apps
1. Build and test an AI service using Azure AI search and Prompt flow
1. Deploy the AI service to the cloud
1. Update your app to leverage the new AI service

To begin, close everything you have open from the first part of this lab.

## Introduction

The Contoso Hotel app is monolithic. Front-end components (HTML, CSS, and JavaScript files) and back-end components (APIs) are all deployed as a single unit. The files required to deploy the legacy app are stored in a GitHub repository. 


## Description

### Setup your account
You will also need to setup an account for your user within the virtual machine you are using for the az login command to work properly.

1. Within your virtual machine, click the **Windows** button enter the following in the search: "account settings" 
1. Click on **Email & accounts**.
1. Click on the **Add a work or school account** link
1. In the Email field, enter the email provided in the Resources of the workshop and click **Next**
1. Enter the password and click "Sign in"

    > :warning: In future steps, whenever you login to Azure from your terminal using `az login` for example, chose the account you just created in the window that pops up.

### Begin the workshop

    > :warning: Throughout this lab, we will be using PowerShell as our terminal withi Visual Studio Code (VS Code). We will begin by opening up powershell, then cloning the required code to our Downloads folder. In addition, you will be advised to store certain values. You are advised to open up a **Notepad ++** instance in the virtual environment and store those values in there for easy access. Also, when you have to modify commands, you are advised to copy the command into notepad and make the edits there as it is easier to do edits in Notepad ++ than directly in the terminal.

In this task, you’ll clone the GitHub repository to the **Downloads** folder on your local machine.

1.  Open File Explorer on your computer and go to the **Downloads** folder.

    ![otderjk6.png](../../media/otderjk6.png)

1. Right click twice in any empty space within the Downloads folder window that isnt a file to open up the menu. The second time you right click on this empty space, you should see **Open in Terminal** as an option. Click on **Open in Terminal**
    ![adsad32](../../media/adsad32.png)
Make sure your terminal is PowerShell. If it isn't, click on the button next to the **+** sign at the top of the terminal to open a new tab within Windows terminal and select Powershell.

1. Enter the command below into your terminal within the Downloads folder to clone the code repository to that folder

    ```powershell
    git clone https://github.com/mosabami/ContosoHotel.git
    ```

1. Change directory of your terminal to the folder created by the clone command and open up Visual Studio code within that folder

    ```powershell
    cd ContosoHotel
    code .
    ```
    Click **Yes, I trust the authors** if prompted.

1. Modify the value of the following variable to reflect the path to the **Downloads** folder on your computer. Enter the command at the Visual Studio Code Terminal window prompt and select **Enter** to set your **Downloads** folder path as a variable.

    ```powershell
    $PATH_TO_DOWNLOADS_FOLDER = "C:\Users\Admin\Downloads"
    ```