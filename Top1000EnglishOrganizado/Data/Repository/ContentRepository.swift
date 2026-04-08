import Foundation

struct ContentRepository {

    // MARK: - WORDS (200 únicas, sem duplicatas)

    let words: [WordItem] = [
        // Substantivos do cotidiano
        ("time","tempo"),("day","dia"),("people","pessoas"),("way","caminho"),
        ("life","vida"),("world","mundo"),("place","lugar"),("problem","problema"),
        ("company","empresa"),("system","sistema"),("question","pergunta"),
        ("number","número"),("night","noite"),("point","ponto"),("water","água"),
        ("room","quarto"),("money","dinheiro"),("story","história"),("month","mês"),
        ("book","livro"),("word","palavra"),("business","negócio"),("side","lado"),
        ("head","cabeça"),("service","serviço"),("friend","amigo"),("family","família"),
        ("power","poder"),("hour","hora"),("game","jogo"),("line","linha"),
        ("law","lei"),("car","carro"),("city","cidade"),("name","nome"),
        ("team","time"),("minute","minuto"),("idea","ideia"),("body","corpo"),
        ("information","informação"),("face","rosto"),("level","nível"),
        ("office","escritório"),("door","porta"),("health","saúde"),("person","pessoa"),
        ("art","arte"),("party","festa"),("result","resultado"),("change","mudança"),
        ("morning","manhã"),("reason","razão"),("research","pesquisa"),
        ("home","casa"),("work","trabalho"),("job","emprego"),("end","fim"),
        ("house","residência"),("program","programa"),("issue","assunto"),
        ("kind","tipo"),("lot","quantidade"),("right","direito"),

        // Verbos essenciais
        ("buy","comprar"),("sell","vender"),("open","abrir"),("close","fechar"),
        ("start","começar"),("finish","terminar"),("help","ajudar"),("call","ligar"),
        ("wait","esperar"),("go","ir"),("come","vir"),("take","pegar"),("give","dar"),
        ("need","precisar"),("want","querer"),("make","fazer"),("find","encontrar"),
        ("try","tentar"),("use","usar"),("ask","perguntar"),("answer","responder"),
        ("know","saber"),("think","pensar"),("say","dizer"),("see","ver"),
        ("get","obter"),("put","colocar"),("keep","manter"),("let","deixar"),
        ("run","correr"),("move","mover"),("play","jogar"),("live","morar"),
        ("feel","sentir"),("bring","trazer"),("read","ler"),("write","escrever"),
        ("pay","pagar"),("send","enviar"),("show","mostrar"),("hear","ouvir"),
        ("learn","aprender"),("eat","comer"),("drink","beber"),("sleep","dormir"),
        ("speak","falar"),("meet","encontrar"),("understand","entender"),
        ("remember","lembrar"),("forget","esquecer"),("choose","escolher"),
        ("lose","perder"),("win","ganhar"),("drive","dirigir"),("travel","viajar"),

        // Adjetivos úteis
        ("good","bom"),("bad","ruim"),("big","grande"),("small","pequeno"),
        ("new","novo"),("old","velho"),("young","jovem"),("long","longo"),
        ("short","curto"),("high","alto"),("low","baixo"),("hot","quente"),
        ("cold","frio"),("fast","rápido"),("slow","devagar"),("easy","fácil"),
        ("hard","difícil"),("free","grátis"),("full","cheio"),("empty","vazio"),
        ("open","aberto"),("closed","fechado"),("ready","pronto"),("busy","ocupado"),
        ("happy","feliz"),("sad","triste"),("tired","cansado"),("hungry","com fome"),
        ("thirsty","com sede"),("sick","doente"),("healthy","saudável"),
        ("beautiful","bonito"),("ugly","feio"),("clean","limpo"),("dirty","sujo"),
        ("safe","seguro"),("dangerous","perigoso"),("important","importante"),
        ("different","diferente"),("same","igual"),("correct","correto"),
        ("wrong","errado"),("early","cedo"),("late","tarde"),("near","perto"),
        ("far","longe"),("cheap","barato"),("expensive","caro"),

        // Advérbios e conectivos
        ("today","hoje"),("tomorrow","amanhã"),("yesterday","ontem"),
        ("now","agora"),("later","depois"),("soon","em breve"),("always","sempre"),
        ("never","nunca"),("sometimes","às vezes"),("usually","geralmente"),
        ("often","frequentemente"),("already","já"),("still","ainda"),
        ("again","de novo"),("also","também"),("only","apenas"),("just","só"),
        ("very","muito"),("really","realmente"),("maybe","talvez"),("yes","sim"),
        ("no","não"),("please","por favor"),("sorry","desculpe"),("thanks","obrigado"),

        // Lugares e objetos
        ("airport","aeroporto"),("hotel","hotel"),("restaurant","restaurante"),
        ("hospital","hospital"),("school","escola"),("bank","banco"),
        ("store","loja"),("market","mercado"),("street","rua"),("road","estrada"),
        ("station","estação"),("train","trem"),("bus","ônibus"),("ticket","passagem"),
        ("phone","telefone"),("computer","computador"),("internet","internet"),
        ("email","email"),("message","mensagem"),("meeting","reunião"),
        ("price","preço"),("cost","custo"),("discount","desconto"),("bill","conta"),
        ("food","comida"),("drink","bebida"),("coffee","café"),("water","água")
    ]
    .enumerated()
    .map {
        WordItem(
            id: "w\($0.offset)",
            en: $0.element.0,
            pt: $0.element.1,
            example: "Use '\($0.element.0)' in a real sentence.",
            tags: ["daily","travel","work"],
            difficulty: ($0.offset % 3) + 1
        )
    }

    // MARK: - PHRASES (80 únicas, sem repetição)

    let phrases: [PhraseItem] = [
        // Pedidos e compras
        ("Can you help me?","Você pode me ajudar?"),
        ("How much is this?","Quanto custa isso?"),
        ("I would like a coffee, please","Quero um café, por favor"),
        ("Where is the bathroom?","Onde é o banheiro?"),
        ("Can I pay by card?","Posso pagar no cartão?"),
        ("Do you accept cash?","Aceita dinheiro?"),
        ("I need a receipt","Preciso de um recibo"),
        ("Can I have the bill?","Pode trazer a conta?"),
        ("Do you have a discount?","Tem desconto?"),
        ("It's too expensive","Está caro demais"),
        ("Can I get a refund?","Posso ter um reembolso?"),
        ("I'll take this one","Vou levar esse"),
        ("Do you have this in another size?","Tem em outro tamanho?"),
        ("One more, please","Mais um, por favor"),
        ("That's enough, thank you","Pode parar, obrigado"),

        // Viagem e transporte
        ("I have a reservation","Tenho uma reserva"),
        ("I need a taxi","Preciso de um táxi"),
        ("Where is the airport?","Onde é o aeroporto?"),
        ("What time does it open?","Que horas abre?"),
        ("What time does it close?","Que horas fecha?"),
        ("Is there a bus to downtown?","Tem ônibus para o centro?"),
        ("How far is it?","Qual a distância?"),
        ("Can you take me to this address?","Pode me levar nesse endereço?"),
        ("I'm lost","Estou perdido"),
        ("Turn right at the corner","Vire à direita na esquina"),
        ("Turn left at the traffic light","Vire à esquerda no semáforo"),
        ("Go straight ahead","Siga em frente"),
        ("How long does it take?","Quanto tempo leva?"),
        ("I missed my flight","Perdi meu voo"),
        ("I need to check in","Preciso fazer o check-in"),

        // Trabalho e reuniões
        ("I'm here for work","Estou aqui a trabalho"),
        ("Let's start the meeting","Vamos começar a reunião"),
        ("Can we reschedule?","Podemos remarcar?"),
        ("I'll send you an email","Vou te enviar um email"),
        ("Can you repeat that?","Pode repetir isso?"),
        ("I don't understand","Não entendo"),
        ("Can you speak more slowly?","Pode falar mais devagar?"),
        ("I agree with you","Concordo com você"),
        ("I disagree","Discordo"),
        ("That's a good idea","É uma boa ideia"),
        ("Let me think about it","Deixa eu pensar"),
        ("I'll get back to you","Te respondo depois"),
        ("Can you explain that again?","Pode explicar de novo?"),
        ("We need to talk","Precisamos conversar"),
        ("What's the deadline?","Qual é o prazo?"),

        // Apresentações e socialização
        ("Nice to meet you","Prazer em te conhecer"),
        ("How are you?","Como você está?"),
        ("I'm doing well, thanks","Estou bem, obrigado"),
        ("What's your name?","Qual é o seu nome?"),
        ("Where are you from?","De onde você é?"),
        ("What do you do for work?","O que você faz?"),
        ("How long have you been here?","Há quanto tempo você está aqui?"),
        ("It's nice to see you again","Que bom te ver de novo"),
        ("Have a great day","Tenha um ótimo dia"),
        ("See you later","Até mais"),
        ("Take care","Se cuida"),
        ("Good luck","Boa sorte"),

        // Situações do dia a dia
        ("I'll be there soon","Chego já"),
        ("I'm running late","Estou atrasado"),
        ("Can you wait a moment?","Pode esperar um momento?"),
        ("Just a second, please","Um segundo, por favor"),
        ("No problem at all","Sem problema nenhum"),
        ("Of course, go ahead","Claro, pode ir"),
        ("That makes sense","Faz sentido"),
        ("I'm not sure about that","Não tenho certeza"),
        ("Let me check","Deixa eu verificar"),
        ("I think so","Acho que sim"),
        ("Maybe later","Talvez depois"),
        ("Not right now","Agora não"),
        ("Can I ask you something?","Posso te perguntar algo?"),
        ("What do you mean?","O que você quer dizer?"),
        ("Is everything okay?","Está tudo bem?"),
        ("I need some help","Preciso de ajuda"),
        ("Could you do me a favor?","Pode me fazer um favor?"),
        ("Thank you so much","Muito obrigado"),
        ("You're welcome","De nada"),
        ("Excuse me","Com licença"),
        ("I'm sorry about that","Me desculpe por isso"),
    ]
    .enumerated()
    .map { idx, pair in
        PhraseItem(
            id: "p\(idx)",
            en: pair.0,
            pt: pair.1,
            tags: ["daily","travel","work"],
            difficulty: (idx % 3) + 1
        )
    }

    // MARK: - SCENARIOS

    let scenarios: [ScenarioItem] = [
        .init(id: "s1", name: "Cafeteria", icon: "cup.and.saucer.fill", description: "Pedidos", tags: ["cafe","daily"]),
        .init(id: "s2", name: "Aeroporto", icon: "airplane.departure", description: "Viagem", tags: ["travel"]),
        .init(id: "s3", name: "Trabalho", icon: "briefcase.fill", description: "Reuniões", tags: ["work"]),
        .init(id: "s4", name: "Compras", icon: "cart.fill", description: "Lojas e mercados", tags: ["daily"]),
        .init(id: "s5", name: "Hotel", icon: "building.2.fill", description: "Reservas e estadia", tags: ["travel"]),
    ]
}
