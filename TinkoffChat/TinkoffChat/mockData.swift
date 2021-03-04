//
//  mockData.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 04.03.2021.
//

import Foundation

var messagesData: [MessageChatData] = [
    MessageChatData(text: "Hello, how are you", date: Date().startOfDay, isMy: true),
    MessageChatData(text: "i'm okay. It was a really hard day today. And now i am feeling little bit lonely. Come over?", date: Date(), isMy: false),
    MessageChatData(text: "Ok. Will be glad to meet you", date: Date().endOfDay, isMy: true),
    MessageChatData(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", date: Date().endOfMonth, isMy: true),
]

var fakeData: [ConversationChatData] = [
    ConversationChatData(name: "Bill Gates", message: "Nah, windows is better than macos. wanna argue about that?", date: Date(), online: true, hasUnreadMessages: true),
    ConversationChatData(name: "Nikita Kazantsev", message: "Hey my friend wanna play Valheim?", date: Date().startOfMonth, online: true, hasUnreadMessages: true),
    ConversationChatData(name: "Elizabeth Guldan", message: "wassap boi how are you today. i am ok, so did you do the work you told me about last date", date: Date(), online: true, hasUnreadMessages: false),
    ConversationChatData(name: "Andrew Durov", message: "okay", date: Date(), online: true, hasUnreadMessages: true),
    ConversationChatData(name: "Arthas the king", message: "Kings do not rule forever my son", date: nil, online: true, hasUnreadMessages: false),
    ConversationChatData(name: nil, message: nil, date: Date(), online: true, hasUnreadMessages: false),
    ConversationChatData(name: "Elizabeth Guldan", message: "wassap boi how are you today. i am ok, so did you do the work you told me about last date", date: Date(), online: true, hasUnreadMessages: false),
    ConversationChatData(name: "Eva Adam", message: nil, date: Date().startOfMonth, online: true, hasUnreadMessages: false),
    ConversationChatData(name: "Such a long name wooooooooow woooooowww", message: nil, date: nil, online: true, hasUnreadMessages: false),
    ConversationChatData(name: nil, message: nil, date: Date(), online: true, hasUnreadMessages: false),
    ConversationChatData(name: "short name", message: "long message ;wdeqwdqwkdxwqnkdwqnkdfkw;qndkn;wqk;dfnk;ndqwk;adsknw;eknwqewqkeqkewqnkekwqewqkewqkeqkewqdqwmqwkcnqwkdwqkdkwq", date: nil, online: true, hasUnreadMessages: false),
    ConversationChatData(name: "John White", message: "Nah, windows is better than macos. wanna argue about that?", date: Date(), online: false, hasUnreadMessages: true),
    ConversationChatData(name: "John Brown", message: "Hey my friend wanna play Valheim?", date: Date().startOfMonth, online: false, hasUnreadMessages: true),
    ConversationChatData(name: "John Yellow", message: "wassap boi how are you today. i am ok, so did you do the work you told me about last date", date: Date(), online: false, hasUnreadMessages: false),
    ConversationChatData(name: "John John", message: "okay", date: Date(), online: false, hasUnreadMessages: true),
    ConversationChatData(name: "Just Joooooooooohn", message: "Kings do not rule forever my son", date: nil, online: false, hasUnreadMessages: false),
    ConversationChatData(name: nil, message: nil, date: Date(), online: false, hasUnreadMessages: false),
    ConversationChatData(name: "Elizabeth Johnson", message: "wassap boi how are you today. i am ok, so did you do the work you told me about last date", date: Date(), online: false, hasUnreadMessages: false),
    ConversationChatData(name: "John Adam", message: nil, date: Date().startOfMonth, online: false, hasUnreadMessages: false),
    ConversationChatData(name: "Such a long John wooooooooow woooooowww", message: nil, date: nil, online: false, hasUnreadMessages: false),
    ConversationChatData(name: nil, message: nil, date: Date(), online: false, hasUnreadMessages: false),
    ConversationChatData(name: "John", message: "long message ;wdeqwdqwkdxwqnkdwqnkdfkw;qndkn;wqk;dfnk;ndqwk;adsknw;eknwqewqkeqkewqnkekwqewqkewqkeqkewqdqwmqwkcnqwkdwqkdkwq", date: nil, online: false, hasUnreadMessages: false),
]
