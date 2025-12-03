"""
LLM Service for IntelliDoc API
Supports multiple LLM providers (OpenAI, Groq, Gemini)
"""

import os
import logging
from typing import Optional, List, Dict, Any

logger = logging.getLogger(__name__)


class LLMService:
    """
    Unified LLM service for translation, chat, and flashcard generation.
    Supports multiple providers with fallback options.
    """
    
    def __init__(self):
        self.provider = None
        self.client = None
        self.model = None
        self._initialize_provider()
    
    def _initialize_provider(self):
        """Initialize LLM provider based on .env configuration"""
        
        # Get provider from .env
        provider_choice = os.getenv("LLM_PROVIDER", "openai").lower()
        
        # OpenAI
        if provider_choice == "openai":
            openai_key = os.getenv("OPENAI_API_KEY")
            if openai_key:
                try:
                    from openai import OpenAI
                    self.client = OpenAI(api_key=openai_key)
                    self.provider = "openai"
                    self.model = os.getenv("LLM_MODEL", "gpt-3.5-turbo")
                    logger.info(f"✅ OpenAI LLM initialized with model: {self.model}")
                    return
                except ImportError:
                    logger.error("❌ OpenAI package not installed. Run: pip install openai")
                except Exception as e:
                    logger.error(f"❌ Failed to initialize OpenAI: {e}")
            else:
                logger.error("❌ OPENAI_API_KEY not found in .env")
        
        # Groq
        elif provider_choice == "groq":
            groq_key = os.getenv("GROQ_API_KEY")
            if groq_key:
                try:
                    from groq import Groq
                    self.client = Groq(api_key=groq_key)
                    self.provider = "groq"
                    self.model = os.getenv("LLM_MODEL", "llama-3.1-8b-instant")
                    logger.info(f"✅ Groq LLM initialized with model: {self.model}")
                    return
                except ImportError:
                    logger.error("❌ Groq package not installed. Run: pip install groq")
                except Exception as e:
                    logger.error(f"❌ Failed to initialize Groq: {e}")
            else:
                logger.error("❌ GROQ_API_KEY not found in .env")
        
        # Google Gemini
        elif provider_choice == "gemini":
            gemini_key = os.getenv("GOOGLE_API_KEY")
            if gemini_key:
                try:
                    import google.generativeai as genai
                    genai.configure(api_key=gemini_key)
                    self.client = genai.GenerativeModel(
                        os.getenv("LLM_MODEL", "gemini-pro")
                    )
                    self.provider = "gemini"
                    self.model = os.getenv("LLM_MODEL", "gemini-pro")
                    logger.info(f"✅ Gemini LLM initialized with model: {self.model}")
                    return
                except ImportError:
                    logger.error("❌ Google GenAI package not installed. Run: pip install google-generativeai")
                except Exception as e:
                    logger.error(f"❌ Failed to initialize Gemini: {e}")
            else:
                logger.error("❌ GOOGLE_API_KEY not found in .env")
        
        else:
            logger.error(f"❌ Unknown LLM_PROVIDER: {provider_choice}. Use: openai, groq, or gemini")
        
        logger.warning("⚠️ No LLM provider initialized. Check your .env configuration.")
    
    def is_available(self) -> bool:
        """Check if LLM service is available"""
        return self.client is not None and self.provider is not None
    
    def _call_llm(self, prompt: str, temperature: float = 0.7, max_tokens: int = 1000) -> str:
        """
        Internal method to call the LLM provider.
        Handles different provider APIs.
        """
        if not self.is_available():
            raise ValueError("LLM service not available. Please configure an API key.")
        
        try:
            if self.provider == "openai":
                response = self.client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=temperature,
                    max_tokens=max_tokens
                )
                return response.choices[0].message.content.strip()
            
            elif self.provider == "groq":
                response = self.client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=temperature,
                    max_tokens=max_tokens
                )
                return response.choices[0].message.content.strip()
            
            elif self.provider == "gemini":
                response = self.client.generate_content(prompt)
                return response.text.strip()
            
            else:
                raise ValueError(f"Unknown provider: {self.provider}")
        
        except Exception as e:
            logger.error(f"LLM call failed: {str(e)}")
            raise
    
    # ============= TRANSLATION METHODS =============
    
    def translate_text(self, text: str, target_language: str, source_language: str = "auto") -> str:
        """
        Translate text to target language using LLM.
        Provides context-aware, idiomatic translation.
        """
        prompt = f"""Translate the following text to {target_language}. 
Provide a natural, idiomatic translation that preserves the meaning and tone.
Only return the translated text, nothing else.

Text to translate:
{text}

Translation in {target_language}:"""
        
        return self._call_llm(prompt, temperature=0.3, max_tokens=2000)
    
    # ============= CHAT METHODS =============
    
    def chat_with_llm(
        self, 
        document_context: str, 
        question: str, 
        language: str = "english",
        conversation_history: Optional[List[Dict]] = None
    ) -> str:
        """
        Answer questions about a document using LLM.
        Supports multilingual responses.
        """
        
        # Build conversation context
        history_text = ""
        if conversation_history:
            for entry in conversation_history[-3:]:  # Last 3 exchanges
                history_text += f"Q: {entry.get('question', '')}\nA: {entry.get('answer', '')}\n\n"
        
        prompt = f"""You are a helpful assistant answering questions about a document.

Document Content:
{document_context[:3000]}

{history_text}
Current Question: {question}

Please answer the question based on the document content in {language}.
Be concise and accurate. If the answer is not in the document, say so.

Answer:"""
        
        return self._call_llm(prompt, temperature=0.5, max_tokens=500)
    
    # ============= FLASHCARD METHODS =============
    
    def generate_flashcards_with_llm(
        self,
        text: str,
        num_cards: int = 10,
        card_type: str = "question_answer",
        language: str = "english",
        difficulty: Optional[str] = None
    ) -> List[Dict[str, str]]:
        """
        Generate flashcards from text using LLM.
        Supports multiple card types and languages.
        """
        
        difficulty_text = f" at {difficulty} difficulty level" if difficulty else ""
        
        prompt = f"""Generate {num_cards} {card_type} flashcards from the following text in {language}{difficulty_text}.

Text:
{text[:2000]}

Create exactly {num_cards} flashcards in JSON format:
[
  {{"question": "...", "answer": "...", "topic": "...", "hint": "..."}},
  ...
]

Only return the JSON array, nothing else."""
        
        response = self._call_llm(prompt, temperature=0.7, max_tokens=2000)
        
        # Parse JSON response
        try:
            import json
            # Extract JSON from response
            start_idx = response.find('[')
            end_idx = response.rfind(']') + 1
            if start_idx != -1 and end_idx > start_idx:
                json_str = response[start_idx:end_idx]
                flashcards = json.loads(json_str)
                return flashcards[:num_cards]
            else:
                # Fallback: create simple flashcards
                return self._generate_fallback_flashcards(text, num_cards)
        except Exception as e:
            logger.error(f"Failed to parse flashcards JSON: {e}")
            return self._generate_fallback_flashcards(text, num_cards)
    
    def _generate_fallback_flashcards(self, text: str, num_cards: int) -> List[Dict[str, str]]:
        """Generate simple fallback flashcards when JSON parsing fails"""
        words = text.split()
        flashcards = []
        
        for i in range(min(num_cards, 5)):
            flashcards.append({
                "question": f"What is covered in section {i+1}?",
                "answer": " ".join(words[i*20:(i+1)*20]),
                "topic": f"Section {i+1}",
                "hint": "Review the document content"
            })
        
        return flashcards
    
    # ============= SUMMARIZATION METHODS =============
    
    def summarize_with_llm(
        self,
        text: str,
        max_length: int = 150,
        language: str = "english"
    ) -> str:
        """
        Summarize text using LLM.
        """
        prompt = f"""Summarize the following text in approximately {max_length} words in {language}.
Be concise and capture the main points.

Text:
{text[:4000]}

Summary:"""
        
        return self._call_llm(prompt, temperature=0.5, max_tokens=max_length * 2)
    
    # ============= UTILITY METHODS =============
    
    def get_info(self) -> Dict[str, Any]:
        """Get information about the LLM service"""
        return {
            "available": self.is_available(),
            "provider": self.provider,
            "model": self.model,
            "capabilities": {
                "translation": True,
                "chat": True,
                "flashcards": True,
                "summarization": True,
                "multilingual": True
            } if self.is_available() else {}
        }


# ============= GLOBAL INSTANCE =============
# Create a singleton instance
llm_service = LLMService()


# ============= CONVENIENCE FUNCTIONS =============
def is_llm_available() -> bool:
    """Quick check if LLM is available"""
    return llm_service.is_available()


def get_llm_info() -> Dict[str, Any]:
    """Get LLM service information"""
    return llm_service.get_info()