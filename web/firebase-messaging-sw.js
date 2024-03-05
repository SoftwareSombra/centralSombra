importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyDir6pzZi6Kr5504YEOgCLsb-mgQ3kL1wE",
    authDomain: "sombratestes.firebaseapp.com",
    projectId: "sombratestes",
    storageBucket: "sombratestes.appspot.com",
    messagingSenderId: "194427576619",
    appId: "1:194427576619:web:5f60071d3993090b37a56e",
    measurementId: "G-YZP0TT3JPQ"
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);
});