clc 
clear 

RateMutacao=0.01;//Taxa de Mutação
RateCrossOver=0.60;//Taxa de Cruzamento
Geracoes=10;//Numero de Gerações
MaxX=5;//Valor máximo para X
MinX=-5;//Valor mínimo para X
MaxY=5;//Valor máximo para Y
MinY=-5;//Valor mínimo para Y
PopSize=10;//Tamanho da População

Bits=20;

//função que cria a população inicial
function[popX]=CriarPopulacao(PopSize)
    popX=int(2*rand(PopSize,Bits));//em binário
    //popY=int(2*rand(PopSize,Bits));//em binário
endfunction


//avalia a fitness 

function valor=ValoresFuncao(x, y)
    //disp(x);
    //disp(y);
    z = 100*(y-x.^2).^2+(1-x).^2; 
    //z=-x.*sin(sqrt(abs(x)))-y.*sin(sqrt(abs(y)));
    //disp(z);
    x=x/250;
    valor=x.*z;
endfunction

function normalizado=Normalizar(valorFuncao)
    max_old=max(valorFuncao);
    normalizado=valorFuncao-max_old; //subtrai todos os valores pelo maior, para que todos se tornem negativos
    normalizado=(-1)*normalizado; //o mais negativo é o que possui melhor fitness ao inverter o sinal
    normalizado=(normalizado+0.1*max_old)*10; //+0.1*max_old para não ter fitness 0, *10 para aumentar a diferença do melhor para o pior 
endfunction


function [Filho1, Filho2]=CrossOver(pai1, pai2, RateCrossOver)
    if rand() <= RateCrossOver then
        corte = int((Bits-1)*rand()) + 1;
        pai1bin=pai1;
        pai2bin=pai2;
        
        // corte do pai1 com auxiliares
        aux1 = pai1bin(1:corte);
        aux2 = pai1bin((corte+1):Bits);
        // corte do pai 2 com auxiliares
        aux3 = pai2bin(1:corte);
        aux4 = pai2bin((corte+1):Bits);
        
        Filho1=[aux1 aux4];
        Filho2=[aux3 aux2];
    else 
        Filho1=pai1;
        Filho2=pai2;
    end
endfunction

function novoFilho=Mutacao(filho, RateMutacao)
    for k=1:Bits
        if rand() <= RateMutacao then
            aux=k;
            invertido=filho(aux);
            if invertido==0 then
                invertido = 1
            else 
                invertido = 0
            end
            filho(aux)=invertido
        end
    end
    novoFilho=filho;
endfunction


function [Menores_Valores, Media_Valores]=GA(PopSize, RateMutacao, RateCrossOver, Geracoes, MinX, MinY, MaxX, MaxY)
    [Xb] = CriarPopulacao(PopSize);
    for K=1:1:Geracoes
        for n=1:1:PopSize
            X(K,n) = MinX+(MaxX-MinX)*(sum(Xb(n,1:10).*(2.0.^[(10-1):-1:0]))/(2^Bits-1));
            Y(K,n) = MinY+(MaxY-MinY)*(sum(Xb(n,11:20).*(2.0.^[(10-1):-1:0]))/(2^Bits-1));   
            disp(X(1,1));
        end
        
        Valores(K,:) = ValoresFuncao(X(K,:), Y(K,:));
        fitness=Normalizar(Valores(K,:));
        
        soma = sum(fitness);
        if soma == 0 then
            disp(soma);
            clf;
        end 
        probabilidadeRoleta=fitness/soma;
        for l=2:PopSize
            probabilidadeRoleta(l)= probabilidadeRoleta(l-1) + probabilidadeRoleta(l);
        end
        
        cross_Over_x = [];
        cross_Over_y = [];
        
        //roleta começa aqui 
        for i=1:1:PopSize
            escolhido = rand();
            posicao = 0;
            acabou = 0;
            while acabou ==0
                posicao = posicao+1;
                if escolhido <= probabilidadeRoleta(posicao);
                    acabou=1;
                end
            end
            cross_Over_x(i,:) = Xb(posicao, :); // pai 
            cross_Over_y(i,:) = Xb(posicao, :); // pai
            
        end
        // crossover começa aqui como só um gene tem os dois valores só preciso fazer isso uma vez
        
        for j=1:2:PopSize
            Pai1_X=cross_Over_x(j,:);
            Pai2_X=cross_Over_x(j+1,:);
            [Filho1_X, Filho2_X] = CrossOver(Pai1_X, Pai2_X, RateCrossOver); // cruza dois pais e gera dois filhos 
            Xb(j,:)=Mutacao(Filho1_X, RateMutacao);
            Xb(j+1,:)=Mutacao(Filho2_X, RateMutacao);
            
        end
        
        Menor_Valor=min(Valores(K,:));
        Menores_Valores(K)=Menor_Valor;
        media=sum(Valores(K,:))/PopSize;
        Media_Valores(K)=media;
    end   
    xtitle('Algoritmo Genético - 356726');
    plot(1:Geracoes, Menores_Valores, 'b');
    plot(1:Geracoes, Media_Valores, 'g');
    xlabel('Gerações');
    ylabel('Valor mínimo por geração');
    legend('Menor Valor', 'Média populacional');
    xgrid();
endfunction

testes = 1;
for i=1:1:testes
    [Menores_Valores2, Media_Valores2]=GA(PopSize, RateMutacao, RateCrossOver, Geracoes, MinX, MinY, MaxX, MaxY);
    Menor(i) = Menores_Valores2(Geracoes);
    disp(Menor(i));    
end
