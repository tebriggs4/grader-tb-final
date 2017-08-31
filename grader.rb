class Grader
    attr_accessor :answer_key, :grades
    
    def initialize(answer_key, **grades)
        @answer_key = answer_key
        @grades = grades[:grades] ||= []
    end
    
    def score(test_answers)
        index = 0
        correct_answers = 0
        if test_answers.length > answer_key.length
            raise(ArgumentError, "Too many answers")
        else
            while index < test_answers.length do
                if ['A','B','C','D',nil].include?(test_answers[index])
                    if (answer_key[index] == test_answers[index])
                        correct_answers += 1
                    end
                else
                    raise(ArgumentError, "Invalid answer")
                end
                index += 1
            end
        end
            score = (correct_answers * 100) / answer_key.length
            if grades == nil
                grades[:grades] = score
            else
                grades << score
            end
            return score
    end

    def self.letter_grade(numerical_score)
        if numerical_score > 100
            raise "Invalid numerical score"
        else
            case numerical_score
            when (90..100)
                return 'A'
            when (80..89)
                return 'B'
            when (75..79)
                return 'C'
            when (70..74)
                return 'D'
            else
                return 'F'
            end
        end
    end

    def curve
        curve_amt = 100 - high_score
        grades.map! do |grades|
            grades += curve_amt
        end
    end
                
    
    def curve_points
        100 - high_score
    end
    
    def average_score
        sum = 0
        grades.each do |grades|
            sum += grades
        end
        return (sum/grades.length)
    end
    
    def high_score
        highest = 0
        grades.each do |grades|
            if grades > highest
                highest = grades
            end
        end
        return highest
    end
    
    def low_score
        lowest = 100
        grades.each do |grades|
            if grades < lowest
                lowest = grades
            end
        end
        return lowest
    end
    
end