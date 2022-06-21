require 'yaml'

module Word
    # words dictionary
    WORDS_FILE = "google-10000-english-no-swears.txt"

    # fetch words from the file
    def get_words
        File.readlines(WORDS_FILE).reduce([]) do |words_list, line|
            word = line.gsub(/\n/, '')
            words_list.push(word) if word.length.between?(5,12)
            words_list
        end
    end
    
    # pick a random word
    def pick_random_word
        get_words.sample
    end
end


class Hangman
    
    include Word

    # positions that will be changing in the hangman array
    @@draw_man = {"24": 'O', "34": '|', "33": "/", "43": "/", "35": "\\", "45": "\\"}

    @@hangman_arr = [
        ['_', '_', '_', '_', '_', ' '],
        ['|', ' ', ' ', ' ', '|', ' '],
        ['|', ' ', ' ', ' ', ' ', ' '],
        ['|', ' ', ' ', ' ', ' ', ' '],
        ['|', ' ', ' ', ' ', ' ', ' '],
        ['|', ' ', ' ', ' ', ' ', ' ']
    ]

    # index that will keep up with the next change position
    @@index = 0
    
    # start the game
    def start
        puts "--- Welcome to Hangman game ---"
        # check if there is a saved game before, also if the player approved to uplode the recent game
        if File.exist?("saved_game.yaml") && uplode_saved_game?
            puts "Loading....."
            games_data =YAML.load File.read('saved_game.yaml')
            # fetch data from the saved game file
            word = games_data[:word]
            player_guess = games_data[:player_guess]
            @@hangman_arr = games_data[:hangman_arr]
            @@index = games_data[:index]
            round = games_data[:round]
            puts "The data have been loaded, Lets start...."
            play(word, player_guess, round)
        else
            # start a new game
            word = pick_random_word
            puts "your word have been picked...."
            puts "your word contains of #{word.length} characters"
            play(word)
        end
    end

    def play(word, player_guess = "_" * word.length, round = 0)
        # each game will have just 10 round
        while round <= 10 do 
            # ask the player to save the game
            save_game?(word, player_guess, round)

            puts "Enter a guess (it should be a character)..."
            guess_chr = gets.chomp
            # make sure that player entered a character
            if (('a'..'z').to_a + ('A'..'Z').to_a).include?(guess_chr)
                guess_chr.downcase!
                # check if the character in the picked word 
                if word.include?(guess_chr)
                    # make sure that the player didn't guess the character before
                    if player_guess.include?(guess_chr)
                        puts "You already gussed this character!!!"
                    else
                        # change all the character that match in thier correct place
                        word.chars.each_with_index do |chr, ind|
                            player_guess[ind] = chr if guess_chr == chr
                        end
                        puts "You guessed right."
                    end
                else
                    puts "Wrong guess -_-. Try again..."
                    round += 1
                    # change the array when the player miss guessing twic
                    change_hangman_arr if round.even?
                end

                # check if the player won
                if !player_guess.include?("_")
                    puts "You Won :)"
                    break
                elsif round > 10
                    change_hangman_arr
                    puts "Will you lost :( The word was #{word}"
                else
                    puts "you have #{10 - round} round remaind!!!"
                end
                
                draw_hangman
                puts "      #{player_guess}"
            
            # player entered wrong character 
            else
                puts "Wrong type of guessing. Try again"
            end
        end
        # ask the player to delete the saved file
        delete_saved_file if File.exist?("saved_game.yaml")
    end

    def save_game?(word, player_guess, round)
        puts "*******************************"
        puts "Do you want to save your game? 1)Yes 2)No"
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                # create a new yaml file to write data on it
                saved_file = File.open("saved_game.yaml","w")
                
                # write the data on the file in YAML shap
                saved_file.puts YAML.dump ({
                    :word => word,
                    :player_guess => player_guess,
                    :hangman_arr => @@hangman_arr,
                    :index => @@index,
                    :round => round
                  })

                puts "Your game have been saved..."
                saved_file.close
                
                return true
            # player do not want to save the game
            else
                puts "Ok, Lets continue then..."
            end
        else
            puts "Please Enter 1 or 2!!!"
            save_game?(word, player_guess, round)
        end
        false
    end

    # ask the player to uplode the previous game or not
    def uplode_saved_game?
        puts "Do you want to..." 
        puts "1)Continue your previous game."
        puts "2)Start new game."
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                return true
            end
        else
            puts "Please Enter 1 or 2!!!"
            uplode_saved_game?
        end
        false
    end

    # print the hangman array
    def draw_hangman
        @@hangman_arr.each do |row|
            puts row.join
        end
    end

    # make changes to the hangman array 
    def change_hangman_arr
        pos = @@draw_man.keys[@@index]
        shap = @@draw_man[pos]
        row = pos[0].to_i
        col = pos[1].to_i
        @@hangman_arr[row][col] = shap
        @@index += 1 
    end

    # ask for delete the file after winning or losing 
    def delete_saved_file
        puts "Do you want to delete saved game? 1)Yes 2)No"
        choice = gets.chomp
        if ["1", "2"].include?(choice)
            if choice == "1"
                File.delete("saved_game.yaml")
            end
        else
            puts "Please Enter 1 or 2!!!"
            delete_saved_file
        end
    end
end
    
Hangman.new().start
