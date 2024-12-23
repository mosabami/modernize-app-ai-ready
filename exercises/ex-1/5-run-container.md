# Task 05 -  Run the containerized app and add a booking

## Introduction

You created a Docker container and pushed the container to ACR in previous tasks. Now, you’ll run the container and view the app in a browser. Since this is the first time you are running the app, you’ll need to run a process to create the database schema and populate the tables with data.

Now, you can view the various pages for the app and try out the features.
 

## Description

In this task, you’ll run the Docker app container and then display the setup page for the app. You’ll create the database schema and populate the tables with data. You’ll review common app pages and add a booking record. Finally, you’ll search for the record you just added to verify that the record was successfully added to the database.

## Learning Resources

[**Manage container images in Azure Container Registry**](
https://learn.microsoft.com/en-us/training/modules/publish-container-image-to-azure-container-registry/ "Manage container images in Azure Container Registry")

## Solution

1. Assuming you successfully created your environment variable for `connectionString` in the previous step, enter the docker run command at the Visual Studio Code Terminal window prompt and then select **Enter**. This command starts the containerized app.
    > :warning: Ensure your Docker Desktop is running before running the command below. If Docker desktop says Docker is stopped, you can close the program and reopen it.

    ```
    docker run -p 8002:8000 -e POSTGRES_CONNECTION_STRING=$env:connectionString pycontosohotel:v1.0.0
    ```

    ![ixlyml4r.png](../../media/ixlyml4r.png)

    > ⚠️ You may minimize Visual Studio Code but don’t close the Visual Studio Code Terminal window at this time.

1. Open a web browser and go to **http://localhost:8002/setup**. The **Contoso Hotel Setup** page displays.

    ![1ri1l25o.png](../../media/1ri1l25o.png)

1. Close the browser tab, head back to VS code terminal and enter **Ctrl + C** multiple times until the process stops so you can use the terminal for future steps.

    > ⚠️ This will not stop the running container. To stop the running container, you will need to stop it in Docker Desktop, which is not a required step in this lab. This means port 8002 will continue to be in use. If you have to run a container again for whatever reason, use a different port than 8002.
