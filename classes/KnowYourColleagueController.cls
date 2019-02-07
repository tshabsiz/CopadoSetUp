public without sharing class KnowYourColleagueController {
    
    @RemoteAction
    public static ChallengeQuestionsWrapper getAllChallengeQuestions(String userId) {
        ChallengeQuestionsWrapper wrap = new ChallengeQuestionsWrapper();
    
        List<User_Question__c> uqs = [SELECT Id, Challenge_Question__c FROM User_Question__c WHERE Questioner__c = :userId];
        wrap.haveChosen = false;
    
        List<ChallengeQuestionDTO> questions = new List<ChallengeQuestionDTO>();
        ChallengeQuestionDTO myQuestion;
        for (Challenge_Question__c question : [SELECT Id, Description__c FROM Challenge_Question__c]) {
            
            if (!uqs.isEmpty() && uqs[0].Challenge_Question__c == question.Id) {
                myQuestion = new ChallengeQuestionDTO();
                myQuestion.description = question.Description__c;
                myQuestion.id = uqs[0].Id;
                wrap.haveChosen = true;
            } else {
                ChallengeQuestionDTO dto = new ChallengeQuestionDTO();
                dto.description = question.Description__c;
                dto.id = question.id;
                questions.add(dto);
            }
        }
        if (myQuestion == null) {
            wrap.questions = questions;
            wrap.answers = new List<Possible_Answer__c>();
        } else {
            wrap.questions = new List<ChallengeQuestionDTO>();
            wrap.questions.add(myQuestion);
            wrap.questions.addAll(questions);
            wrap.answers = [SELECT Id, Description__c FROM Possible_Answer__c WHERE Question__c = :myQuestion.id];
        }
        
        return wrap;
    }
    
    @RemoteAction
    public static ChallengeQuestionsWrapper setQuestionAsMine(String questionId, String userId) {
        List<User_Question__c> uqs = [SELECT Id FROM User_Question__c WHERE Questioner__c = :userId];
        if (!uqs.isEmpty()) {
            delete uqs;
        }
        
        User_Question__c uq = new User_Question__c();
        uq.Challenge_Question__c = questionId;
        uq.Questioner__c = userId;
        insert uq;
        
        return getAllChallengeQuestions(userId);
    }
    
    @RemoteAction
    public static ChallengeQuestionsWrapper addAnswer(String answer, String questionId, String userId) {
        Possible_Answer__c pa = new Possible_Answer__c();
        pa.Description__c = answer;
        pa.Question__c = questionId;
        insert pa;
    
        return getAllChallengeQuestions(userId);
    }
    
    @RemoteAction
    public static List<User> searchUser(String searchString) {
        searchString += '*';
        String searchQuery = 'FIND \'' + searchString + '\' IN ALL FIELDS RETURNING User(Firstname, Lastname, Name)';
        List<List<sObject>> searchList = search.query(searchQuery);
        return searchList[0];
    }
    
    @RemoteAction
    public static String setAnswerData(String answerId, Boolean isCorrect) {
        Users_Answer__c ua = new Users_Answer__c();
        ua.Possible_Answer__c = answerId;
        ua.Correct__c = isCorrect;
        insert ua;
        
        List<Possible_Answer__c> pas = [SELECT Question__r.Questioner__c FROM Possible_Answer__c WHERE Id = :answerId];
        return pas[0].Question__r.Questioner__c;
    }
    
    @RemoteAction
    public static UserQuestion getUserQuestion(String userId) {
        //querying correct answer
        List<Possible_Answer__c> pas = [
            SELECT Id, Description__c, Question__r.Questioner__r.Name, Question__r.Challenge_Question__c, Question__r.Challenge_Question__r.Description__c 
            FROM Possible_Answer__c 
            WHERE Question__r.Questioner__c = :userId];
        
        UserQuestion uq = new UserQuestion();
        if (pas.isEmpty()) {
            uq.hasChosen = false;
            return uq;
        }
        uq.hasChosen = true;
        
        //check if user has already aswered
        List<Users_Answer__c> uas = [SELECT Id FROM Users_Answer__c WHERE Possible_Answer__c = :pas[0].Id AND CreatedById = :UserInfo.getUserId()];
        if (!uas.isEmpty()) {
            uq.alreadyAnswered = true;
            return uq;
        }
        
        Possible_Answer__c pa = pas[0];
        uq.username = pa.Question__r.Questioner__r.Name;
        
        String questionId = pa.Question__r.Challenge_Question__c;
        
        ChallengeQuestionDTO question = new ChallengeQuestionDTO();
        question.description = pa.Question__r.Challenge_Question__r.Description__c;
        uq.question = question;
        
        Integer count = Database.countQuery(
            'SELECT count() FROM Possible_Answer__c WHERE Question__r.Challenge_Question__c = :questionId AND Description__c != \'' + pa.Description__c + '\'');
        System.debug('count: ' + count);
            
        Double offsetD = Math.random() * count;
        Integer offset = (Integer) offsetD;
        
        System.debug('offset: ' + offset);
        
        //correct answer
        if (offset != 0) {
            offset--;
        }
        
        //last rows check
        if ((offset - 2) >= 0) {
            offset -= 2;
        }
        
        System.debug('offset: ' + offset);
        
        List<Possible_Answer__c> fakeAswers = [
            SELECT Id, Description__c
            FROM Possible_Answer__c 
            WHERE Id != :pa.Id AND Question__r.Challenge_Question__c = :questionId AND Description__c != :pa.Description__c
            LIMIT 2
            OFFSET :offset];
        
        PossibleAnswerDTO correctAnswer = new PossibleAnswerDTO();
        correctAnswer.isCorrect = true;
        correctAnswer.id = pa.Id;
        correctAnswer.description = pa.Description__c;
        
        PossibleAnswerDTO fakeAnswer1 = new PossibleAnswerDTO();
        fakeAnswer1.isCorrect = false;
        fakeAnswer1.description = fakeAswers[0].Description__c;
        fakeAnswer1.id = fakeAswers[0].Id;
        
        PossibleAnswerDTO fakeAnswer2 = new PossibleAnswerDTO();
        fakeAnswer2.isCorrect = false;
        fakeAnswer2.description = fakeAswers[1].Description__c;
        fakeAnswer2.id = fakeAswers[1].Id;
        
        Double correctAnswerPositionD = Math.random() * 3;
        Integer correctAnswerPosition = (Integer) correctAnswerPositionD;
        
        if (correctAnswerPosition == 1) {
            uq.answers = new List<PossibleAnswerDTO>{correctAnswer, fakeAnswer1, fakeAnswer2};
        } else if (correctAnswerPosition == 2) {
            uq.answers = new List<PossibleAnswerDTO>{fakeAnswer1, correctAnswer, fakeAnswer2};
        } else {
            uq.answers = new List<PossibleAnswerDTO>{fakeAnswer2, fakeAnswer1, correctAnswer};
        }  

        return uq;
    }
    
    @testVisible
    private class UserQuestion {
    
        public Boolean hasChosen;
        public Boolean alreadyAnswered;
        public String username;
        public ChallengeQuestionDTO question;
        public List<PossibleAnswerDTO> answers;
        
    }
    
    @testVisible
    private class ChallengeQuestionsWrapper {
        
        public List<ChallengeQuestionDTO> questions;
        public List<Possible_Answer__c> answers;
        public Boolean haveChosen;
        
    }
    
    @testVisible
    private class ChallengeQuestionDTO {
    
        public String description;
        public String id;
        
    }
    
    @testVisible
    private class PossibleAnswerDTO {
    
        public String description;
        public String id;
        public Boolean isCorrect;
    
    }

}