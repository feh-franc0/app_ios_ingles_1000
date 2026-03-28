import Foundation

struct ContentRepository {
    let words: [WordItem] = [
        .init(id: "w1", en: "because", pt: "porque", example: "I stayed because I was happy.", tags: ["work","daily"], difficulty: 1),
        .init(id: "w2", en: "always", pt: "sempre", example: "I always study at night.", tags: ["daily"], difficulty: 1),
        .init(id: "w3", en: "maybe", pt: "talvez", example: "Maybe we can go tomorrow.", tags: ["travel","daily"], difficulty: 1),
        .init(id: "w4", en: "before", pt: "antes", example: "Call me before you leave.", tags: ["travel"], difficulty: 2),
        .init(id: "w5", en: "after", pt: "depois", example: "We will talk after lunch.", tags: ["daily"], difficulty: 2),
        .init(id: "w6", en: "between", pt: "entre", example: "Between 5 and 6 pm.", tags: ["work"], difficulty: 2),
        .init(id: "w7", en: "around", pt: "por volta de", example: "Around 7 o’clock.", tags: ["travel"], difficulty: 2),
        .init(id: "w8", en: "enough", pt: "suficiente", example: "That’s enough for today.", tags: ["daily"], difficulty: 3),
        .init(id: "w9", en: "often", pt: "frequentemente", example: "I often practice speaking.", tags: ["daily"], difficulty: 2),
        .init(id: "w10", en: "usually", pt: "geralmente", example: "I usually wake up early.", tags: ["daily"], difficulty: 2),
        .init(id: "w11", en: "quick", pt: "rápido", example: "A quick call.", tags: ["work"], difficulty: 2),
        .init(id: "w12", en: "slow", pt: "lento", example: "Speak slow, please.", tags: ["travel"], difficulty: 2),
        .init(id: "w13", en: "cheap", pt: "barato", example: "This is cheap.", tags: ["travel"], difficulty: 2),
        .init(id: "w14", en: "expensive", pt: "caro", example: "It’s too expensive.", tags: ["travel"], difficulty: 2),
        .init(id: "w15", en: "help", pt: "ajuda", example: "Can you help me?", tags: ["travel","daily"], difficulty: 1),
        .init(id: "w16", en: "right", pt: "certo / direita", example: "Turn right.", tags: ["travel"], difficulty: 2),
        .init(id: "w17", en: "left", pt: "esquerda", example: "Turn left.", tags: ["travel"], difficulty: 2),
        .init(id: "w18", en: "open", pt: "abrir / aberto", example: "Is the store open?", tags: ["travel"], difficulty: 1),
        .init(id: "w19", en: "close", pt: "fechar / perto", example: "Close the door.", tags: ["daily"], difficulty: 1),
        .init(id: "w20", en: "ready", pt: "pronto", example: "I’m ready.", tags: ["work","daily"], difficulty: 1),
    ]

    let phrases: [PhraseItem] = [
        .init(id: "p1", en: "Could you help me?", pt: "Você pode me ajudar?", tags: ["travel","daily"], difficulty: 1),
        .init(id: "p2", en: "How much is this?", pt: "Quanto custa isso?", tags: ["travel"], difficulty: 1),
        .init(id: "p3", en: "I would like a coffee, please.", pt: "Eu gostaria de um café, por favor.", tags: ["cafe","travel"], difficulty: 1),
        .init(id: "p4", en: "Where is the bathroom?", pt: "Onde é o banheiro?", tags: ["travel"], difficulty: 1),
        .init(id: "p5", en: "I have a reservation.", pt: "Eu tenho uma reserva.", tags: ["hotel","travel"], difficulty: 1),
        .init(id: "p6", en: "Can you speak slowly?", pt: "Você pode falar devagar?", tags: ["travel"], difficulty: 1),
        .init(id: "p7", en: "What time does it open?", pt: "Que horas abre?", tags: ["travel"], difficulty: 2),
        .init(id: "p8", en: "I’m here for work.", pt: "Eu estou aqui a trabalho.", tags: ["work"], difficulty: 1),
        .init(id: "p9", en: "Let’s start the meeting.", pt: "Vamos começar a reunião.", tags: ["work"], difficulty: 2),
        .init(id: "p10", en: "I will be there in 10 minutes.", pt: "Eu estarei aí em 10 minutos.", tags: ["daily"], difficulty: 2),
        .init(id: "p11", en: "I don’t understand.", pt: "Eu não entendo.", tags: ["daily"], difficulty: 1),
        .init(id: "p12", en: "Can I pay by card?", pt: "Posso pagar no cartão?", tags: ["travel"], difficulty: 1),
        .init(id: "p13", en: "I’m looking for this address.", pt: "Estou procurando este endereço.", tags: ["travel"], difficulty: 2),
        .init(id: "p14", en: "I need a taxi.", pt: "Eu preciso de um táxi.", tags: ["travel"], difficulty: 1),
        .init(id: "p15", en: "One more, please.", pt: "Mais um, por favor.", tags: ["cafe","daily"], difficulty: 1),
        .init(id: "p16", en: "That’s enough for today.", pt: "Isso é suficiente por hoje.", tags: ["daily"], difficulty: 2),
        .init(id: "p17", en: "I’m ready.", pt: "Eu estou pronto.", tags: ["daily"], difficulty: 1),
        .init(id: "p18", en: "Turn right.", pt: "Vire à direita.", tags: ["travel"], difficulty: 1),
        .init(id: "p19", en: "Turn left.", pt: "Vire à esquerda.", tags: ["travel"], difficulty: 1),
        .init(id: "p20", en: "It’s too expensive.", pt: "Está caro demais.", tags: ["travel"], difficulty: 2),
    ]

    let scenarios: [ScenarioItem] = [
        .init(id: "s1", name: "Cafeteria", icon: "cup.and.saucer.fill", description: "Pedir, pagar, agradecer.", tags: ["cafe","daily"]),
        .init(id: "s2", name: "Aeroporto", icon: "airplane.departure", description: "Check-in, portão, horários.", tags: ["travel"]),
        .init(id: "s3", name: "Trabalho", icon: "briefcase.fill", description: "Reuniões, prazos, status.", tags: ["work"]),
    ]
}
