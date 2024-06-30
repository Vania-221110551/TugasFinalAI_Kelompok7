import cv2
import numpy as np
from PIL import Image, ImageTk
import os
import tkinter as tk
from tkinter import messagebox
import mysql.connector
import re

current_id = None
script_dir = os.path.dirname(os.path.abspath(__file__))

def get_current_id():
    global current_id

    files = os.listdir('./faces_data') #--> List semua file di directory 'faces_data'
    highest_user_id = 0 #--> Untuk simpan user id yang paling besar (paling terakhir)

    pattern = re.compile(r'user\.(\d+)\.10') #--> Regex pattern untuk cek apakah format file sesuai

    for filename in files:
        match = pattern.match(filename)
        if match:
            current_id = int(match.group(1))
            if current_id > highest_user_id:
                highest_user_id = current_id

    current_id = highest_user_id + 1 #--> set current_id untuk user berikutnya

def generate_dataset():
    get_current_id()
    if (t1.get()=="" or t2.get()==""):
        messagebox.showinfo('Result', "Please complete the input text box")
    else:
      mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            passwd="",
            database="Authorized_user"
        )

      sql = f"INSERT INTO my_table (id, name, role) VALUES (%s, %s, %s)" #--> tidak menambahkan id karena AUTO_INCREMENT
      val = (current_id, t1.get(), t2.get())
      mycursor = mydb.cursor()
      mycursor.execute(sql, val)
      mydb.commit()

      face_classifier = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
      def crop_face(img):
          # convert gambar ke grayscale image
          gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
          # scaling factor = 1.3 & minimum neighbor = 5
          faces = face_classifier.detectMultiScale(gray, 1.3, 5)
          
          if faces is ():
            return None
          for (x, y, w, h) in faces:
            cropped_face = img[y:y+h, x:x+w]
          return cropped_face

      cap = cv2.VideoCapture(0)
      img_id = 0
      while True:
          ret, frame = cap.read()
          if crop_face(frame) is not None:
              img_id += 1
              face = cv2.resize(crop_face(frame), (200, 200))
              face = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
              file_name_path = 'faces_data/user.' + str(current_id) + '.' + str(img_id) + '.jpg'
              cv2.imwrite(file_name_path, face)
              cv2.putText(face, str(img_id), (50, 50), cv2.FONT_HERSHEY_COMPLEX, 1, (0, 255, 0), 2) # posisi tulisan ditulis -> (50,50), font scale -> 1, thickness -> 2
              cv2.imshow('Cropped face', face)

              if cv2.waitKey(1) == 13 or int(img_id) == 100: #--> 13 adalah ASCII dari Enter, jadi tekan enter untuk berhenti looping
                  break

      cap.release() #--> close capture
      cv2.destroyAllWindows()
      messagebox.showinfo('Result', 'Generating dataset completed...')

def train_classifier():
    data_dir = os.path.join(script_dir, 'faces_data')
    path = [os.path.join(data_dir, f) for f in os.listdir(data_dir)] #--> melakukan perulangan di nama file
    faces = []
    ids = []

    for image in path:
        img = Image.open(image).convert('L') #--> convert gambar ke grayscale
        imageNp = np.array(img, 'uint8')
        id = int(os.path.split(image)[-1].split('.')[1])
        # menambahkan data yang sudah di split ke dalam list
        faces.append(imageNp)
        ids.append(id)
    ids = np.array(ids)

    # Train the classifier and save
    clf = cv2.face_LBPHFaceRecognizer.create()
    clf.train(faces, ids)
    clf.write('classifier.xml')
    messagebox.showinfo('Result', "Training dataset completed...")

def draw_rectangle(img, classifier, scaleFactor, minNeighbors, color, text, clf):
    gray_image = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    features = classifier.detectMultiScale(gray_image, scaleFactor, minNeighbors)

    coords = []

    for (x, y, w, h) in features:
        cv2.rectangle(img, (x, y), (x+w, y+h), color, 2) #--> gambar kotak disekeliling wajah
        pred_id, pred = clf.predict(gray_image[y:y+h, x:x+w])
        confidence = int(100 * (1-pred/300))

        mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            passwd="",
            database="Authorized_user"
        )
        mycursor = mydb.cursor()
        mycursor.execute(f"SELECT name, role FROM my_table WHERE id={str(pred_id)}")
        s = mycursor.fetchone()

        if s is not None:
            name, role = s # Unpack the tuple into name and role
            text= f"{name} - {role}"
        else:
            text = "Unknown"

        if confidence > 80: #--> bisa diset makin kecil
          cv2.putText(img, text, (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, color, 1, cv2.LINE_AA) #--> Tambahkan teks dibagian atas kotak
        else:
            cv2.putText(img, "Unknown", (x, y-5), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0,0,255), 1, cv2.LINE_AA)

        coords = [x, y, w, h]
    return coords

def recognize(img, clf, faceCascade):
    coords = draw_rectangle(img, faceCascade, 1.1, 10, (255, 255, 255), "Face", clf)
    return img

def detect_face():
    faceCascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    clf = cv2.face.LBPHFaceRecognizer_create()
    clf.read('classifier.xml')

    video_capture = cv2.VideoCapture(0)

    while True:
        ret, img = video_capture.read()
        img = recognize(img, clf, faceCascade)
        cv2.imshow('Face Recognizer', img)

        if cv2.waitKey(1) == 13:
          break

    video_capture.release()
    cv2.destroyAllWindows()

    # crop face, convert it to gray image --> classifier
    # to draw image, need to give real image from webcam, not from gray image

# GUI untuk Face Aplikasi Face Recognition
window = tk.Tk()
window.title("Face Recognition System")
window.config(background="white")

# Foto
photo_path = os.path.join(script_dir, "logo.png")
img = Image.open(photo_path)
img = img.resize((700, 200), Image.LANCZOS)
photo = ImageTk.PhotoImage(img)
photo_label = tk.Label(window, image=photo, bg="white")
photo_label.grid(column=0, row=0, columnspan=3, pady=10)

# Input Name
l1 = tk.Label(window, text="Name", font=("Arial", 18), bg="white") #--> put it inside window
l1.grid(column = 0, row = 1, padx = 10) #--> posisi labelnya
t1 = tk.Entry(window, width = 50, bd = 5, font=("Arial", 12)) #--> bd is border
t1.grid(column = 1, row = 1, padx = 10) #--> posisi inputannya

# Input Role
l2 = tk.Label(window, text="Role", font=("Arial", 18), bg="white")
l2.grid(column = 0, row = 2, padx = 10)
t2 = tk.Entry(window, width = 50, bd = 5, font=("Arial", 12))
t2.grid(column = 1, row = 2, padx = 10)


# Button for Training
b1 = tk.Button(window, text="Training", font=("Arial", 18), bg="blue", fg="white", command=train_classifier)
b1.grid(column = 0, row = 3, pady = 30)

# Button for Detecting Face
b2 = tk.Button(window, text="Detect Face", font=("Arial", 18), bg="blue", fg="white", command=detect_face)
b2.grid(column = 1, row = 3, pady = 30)

# Button for Generating Dataset
b3 = tk.Button(window, text="Generate Dataset", font=("Arial", 18), bg="blue", fg="white", command=generate_dataset)
b3.grid(column = 2, row = 3, pady = 30)

window.geometry("800x500")
window.mainloop()