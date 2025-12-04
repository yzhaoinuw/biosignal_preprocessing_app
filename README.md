# Installation
Click the green **Code** button, then click **Download ZIP**. Unzip the app folder to your preferred location on your computer.
> Note: it is recommended that you have MATLAB 2022 or later installed to run this app.

# Usage
1. Open the app folder and double click **app.mlapp**. When the app opens, you will be in the Home page. First, enter the **Subject ID**. Then add the path to TDT folder if you have fiberphotometry (fp) data and path to the .exp file if you have EEG/EMG data recorded using Viewpoint, or the path to the .edf file if you have EEG/EMG data recorded on Sirenia. Click **Continue** when you are done. 
> Note: You should organize your EEG/EMG data such that there's only one .exp file or one .edf file in a folder. For Sirenia, only .edf files is supported.
<img width="802" height="638" alt="home_page" src="https://github.com/user-attachments/assets/2ce35163-c0e2-4f56-828f-98af0b1dc4c0" />

\
2. If you provided a path to TDT files in step 1, you will now see a page that asks you about the TDT channel information. Fill out the biosignal that you wish to extract in the channels listed. The channels for which you don't provide a name will not be extracted and will not be included in the output .mat file. Click **Continue** when done.
> Note: The **Reference Channel** (isosbestic channel) is used to normalize the signal recorded in the corresponding channel. **TTL Channel** is only used if you also had EEG/EMG data in step 1, and is used to synchronize the fp data with EEG/EMG data. Otherwise, select "none" from drop down options. If you also have event or period labels recorded, then please also provide the channel for those labels. Otherwise, leave it as" none".
<img width="802" height="638" alt="TDT_page" src="https://github.com/user-attachments/assets/8e5c1c18-7ea8-429e-a0c3-8239a95cc3ab" />

\
3. Now the app will extract and preprocess the data you specified. You can see the progress in this page. When done, you can save the output .mat file to a preferred location by clicking **Save File**.


<img width="802" height="638" alt="save_page" src="https://github.com/user-attachments/assets/786de8a5-c5ca-4556-8b40-d5874ad1585b" />


# Additional Notes
While this app has been tested on files provided by some experimenters, it is possible that it does not foresee and accommodate your data if recorded differently. If you run into any issues with the app, please check that if there's an error message in the MATLAB console that's displayed in red. Copy and share that error message with Yue.

