importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD4ZQW9FCSq3LB3oxuDJwBcVYCivE3cDJA",
  authDomain: "geo-fencing-8970a.firebaseapp.com",
  projectId: "geo-fencing-8970a",
  storageBucket: "geo-fencing-8970a.firebasestorage.app",
  messagingSenderId: "157337589469",
  appId: "1:157337589469:web:68b5168f9f7cd2e85aed34",
  measurementId: "G-HCLV96RL15"
});

const messaging = firebase.messaging();